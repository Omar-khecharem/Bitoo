import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/animations/curves.dart';
import '../../../music_engine/core/audio_extensions.dart';
import '../../../music_engine/presentation/providers/music_engine_provider.dart';
import '../../domain/entities/playback_state.dart';
import '../widgets/album_art_view.dart';
import '../widgets/seek_bar.dart';
import '../widgets/player_controls.dart';
import '../providers/player_provider.dart';

class FullscreenPlayerPage extends ConsumerStatefulWidget {
  final String filePath;
  final String title;
  final String artist;
  final VoidCallback? onClose;
  final double expandProgress;
  final AnimationController? overlayController;

  const FullscreenPlayerPage({
    super.key,
    required this.filePath,
    this.title = '',
    this.artist = '',
    this.onClose,
    this.expandProgress = 1.0,
    this.overlayController,
  });

  @override
  ConsumerState<FullscreenPlayerPage> createState() => _FullscreenPlayerPageState();
}

class _FullscreenPlayerPageState extends ConsumerState<FullscreenPlayerPage>
    with SingleTickerProviderStateMixin {
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;

  // Entrance animation (only for Navigator route)
  AnimationController? _entryController;
  Animation<double>? _entryAnimation;

  // Gesture state
  Offset _dragStart = Offset.zero;

  // Player state
  AlbumArtMode _artMode = AlbumArtMode.standard;
  bool _isPlaying = true;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.7;
  RepeatMode _repeatMode = RepeatMode.all;
  bool _isShuffled = false;
  bool _isFavorite = false;
  double get _amplitude => 0.0;
  String _filePath = '';
  String _title = '';
  String _artist = '';

  bool get _isOverlay => widget.overlayController != null;
  double get _t => _isOverlay ? widget.expandProgress : (_entryAnimation?.value ?? 1.0);

  @override
  void initState() {
    super.initState();
    _filePath = widget.filePath;
    _title = widget.title;
    _artist = widget.artist;
    if (_isOverlay) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ));
    } else {
      _entryController = AnimationController(
        vsync: this,
        duration: AppDurations.complex,
      )..forward();
      _entryAnimation = CurvedAnimation(
        parent: _entryController!,
        curve: AnimationCurves.premiumEaseOut,
      );
    }
    _initPlayer();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    if (_filePath.isEmpty) return;
    try {
      final repo = await ref.read(musicRepositoryProvider.future);
      final fav = await repo.isFavorite(_filePath);
      if (mounted) setState(() => _isFavorite = fav);
    } catch (_) {}
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _entryController?.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    final handler = ref.read(audioHandlerProvider);
    _stateSub = handler.playbackState.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
    _posSub = handler.playbackState.listen((state) {
      if (mounted) setState(() => _position = state.position);
    });
    _durSub = handler.mediaItem.listen((item) {
      if (item == null || !mounted) return;
      setState(() {
        _duration = item.duration ?? _duration;
        _filePath = item.id;
        _title = item.title;
        _artist = item.artist ?? '';
      });
      _loadFavoriteStatus();
    });
  }

  void _closePlayer() {
    if (_isOverlay) {
      widget.overlayController?.reverse();
    } else {
      if (widget.onClose != null) {
        widget.onClose!();
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _onVolumeChanged(double v) {
    setState(() => _volume = v);
    ref.read(audioHandlerProvider).setVolume(v);
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isOverlay) return;
    final ctrl = widget.overlayController;
    if (ctrl == null) return;
    final delta = details.globalPosition - _dragStart;
    final dragFraction = (delta.dy / 400).clamp(0.0, 1.0);
    ctrl.value = (1.0 - dragFraction).clamp(0.0, 1.0);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_isOverlay) {
      if (details.primaryVelocity! > 300) _closePlayer();
      return;
    }
    final ctrl = widget.overlayController;
    if (ctrl == null) return;

    final value = ctrl.value;
    final velocity = details.primaryVelocity!;
    const double dismissThreshold = 0.25;
    const double restoreThreshold = 0.4;
    const double minVelocity = 300.0;

    if (value < dismissThreshold) {
      ctrl.reverse();
    } else if (value > restoreThreshold) {
      ctrl.forward();
    } else if (velocity.abs() > minVelocity) {
      if (velocity > 0) {
        ctrl.reverse();
      } else {
        ctrl.forward();
      }
    } else {
      ctrl.forward();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final handler = ref.read(audioHandlerProvider);
    if (details.primaryVelocity! > 300) {
      handler.skipToPrevious();
    } else if (details.primaryVelocity! < -300) {
      handler.skipToNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Non-overlay mode: use entry animation as before
    if (!_isOverlay) {
      return AnimatedBuilder(
        animation: _entryAnimation!,
        builder: (context, child) {
          final value = _entryAnimation!.value.clamp(0.0, 1.0);
          final scale = 0.88 + (value * 0.12);
          return Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()..scale(scale, scale, 1),
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 400),
              child: Opacity(
                opacity: value,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: _buildContent(false),
                ),
              ),
            ),
          );
        },
      );
    }

    // Overlay mode: use expandProgress for morphing
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildContent(true),
    );
  }

  Widget _buildContent(bool morph) {
    final mq = MediaQuery.of(context);
    final t = _t.clamp(0.0, 1.0);
    final isLandscape = mq.orientation == Orientation.landscape;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: morph && t < 1.0
          ? null
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDark ? AppColors.darkBackground : AppColors.lightSurfaceDark,
                  isDark ? const Color(0xFF0A0A1A) : AppColors.lightSurface,
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
                ],
              ),
            ),
      child: Stack(
        children: [
          // Background blur layer
          if (morph)
            Positioned.fill(
              child: Opacity(
                opacity: t,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary500.withValues(alpha: 0.15),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Main content: full player layout
          SafeArea(
            child: GestureDetector(
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: morph
                  ? _buildMorphingLayout(t, isLandscape)
                  : (isLandscape
                      ? _buildLandscapeLayout()
                      : _buildPortraitLayout()),
            ),
          ),
          // Drag handle
          if (!morph || t > 0.5)
            Positioned(
              top: mq.padding.top + 8,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _closePlayer,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.darkTextTertiary.withValues(alpha: 0.3 * (morph ? (t - 0.5) / 0.5 : 1.0)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMorphingLayout(double t, bool isLandscape) {
    if (isLandscape) return _buildLandscapeLayout();

    // At t >= 1.0, show pure full player layout
    if (t >= 1.0) return _buildPortraitLayout();

    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final bottomInset = mq.padding.bottom;

    // Mini player constants
    const miniArtSize = 48.0;
    const miniHeight = 80.0;
    final miniBottom = bottomInset;

    // Full player art size
    final fullArtSize = screenWidth * 0.72;

    // Interpolated values
    final artSize = lerpDouble(miniArtSize, fullArtSize, t)!;
    final artLeft = lerpDouble(Spacing.md, (screenWidth - fullArtSize) / 2, t)!;
    final artBottom = lerpDouble(miniBottom + (miniHeight - miniArtSize) / 2, mq.size.height * 0.35, t)!;
    final titleSize = lerpDouble(15, 24, t)!;
    final artistSize = lerpDouble(12, 14, t)!;
    final titleLeft = lerpDouble(miniArtSize + Spacing.md + Spacing.md, 0, t)!;
    final titleBottom = lerpDouble(miniBottom + miniHeight / 2 + 2, mq.size.height * 0.35 + fullArtSize * 0.6 + Spacing.xl, t)!;
    final controlsOpacity = (t < 0.3 ? 1.0 - (t / 0.3) : 0.0).clamp(0.0, 1.0);
    const fullControlsStart = 0.3;
    final fullControlsOpacity = (t < fullControlsStart ? 0.0 : (t - fullControlsStart) / (1.0 - fullControlsStart)).clamp(0.0, 1.0);

    return Stack(
      children: [
        // Full portrait layout (fades in)
        Opacity(
          opacity: fullControlsOpacity,
          child: Transform.translate(
            offset: Offset(0, (1 - fullControlsOpacity) * 120),
            child: IgnorePointer(
              ignoring: t < 0.8,
              child: Opacity(
                opacity: ((t - 0.5) / 0.5).clamp(0.0, 1.0),
                child: _buildPortraitLayout(),
              ),
            ),
          ),
        ),
        // Mini player row (fades out, slides down)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Transform.translate(
            offset: Offset(0, t * miniHeight * 0.5),
            child: Opacity(
              opacity: 1.0 - (t / 0.4).clamp(0.0, 1.0),
              child: _buildMiniRow(
                artSize: miniArtSize,
                titleSize: 15,
                artistSize: 12,
                showControls: false,
                controlsOpacity: controlsOpacity,
                showProgress: true,
              ),
            ),
          ),
        ),
        // Morphing album art
        Positioned(
          left: artLeft,
          bottom: artBottom,
          child: SizedBox(
            width: artSize,
            height: artSize,
            child: AlbumArtView(
              imageUrl: 'https://via.placeholder.com/400',
              size: artSize,
              mode: _artMode,
              isPlaying: _isPlaying,
              amplitude: _amplitude,
              onModeToggle: () {},
            ),
          ),
        ),
        // Title + Artist (morphing)
        Positioned(
          left: titleLeft,
          right: Spacing.lg,
          bottom: titleBottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _title.isNotEmpty ? _title : AudioExtensions.titleFromPath(_filePath),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: titleSize,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: lerpDouble(2, Spacing.xs, t)!),
              Text(
                _artist.isNotEmpty ? _artist : 'Feel the sound',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: artistSize,
                  color: const Color(0xFFA6A6A6),
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Controls at bottom right (only during morph)
        if (controlsOpacity > 0)
          Positioned(
            right: Spacing.sm,
            bottom: miniBottom + (miniHeight - 40) / 2,
            child: Opacity(
              opacity: controlsOpacity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MorphMiniButton(
                    icon: Icons.skip_previous_rounded,
                    onTap: () => ref.read(audioHandlerProvider).skipToPrevious(),
                  ),
                  _MorphPlayButton(
                    isPlaying: _isPlaying,
                    progress: _duration.inMicroseconds > 0
                        ? (_position.inMicroseconds / _duration.inMicroseconds).clamp(0.0, 1.0)
                        : 0.0,
                    onTap: () {
                      final h = ref.read(audioHandlerProvider);
                      if (_isPlaying) { h.pause(); } else { h.play(); }
                    },
                  ),
                  _MorphMiniButton(
                    icon: Icons.skip_next_rounded,
                    onTap: () => ref.read(audioHandlerProvider).skipToNext(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMiniRow({
    required double artSize,
    required double titleSize,
    required double artistSize,
    required bool showControls,
    required double controlsOpacity,
    required bool showProgress,
  }) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;

    return Container(
      height: 80 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkSurfaceLight.withValues(alpha: 0.95),
            AppColors.darkSurface.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: const Radius.circular(AppRadius.xl)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: const Radius.circular(AppRadius.xl)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.sm, Spacing.sm),
          child: Row(
            children: [
              Container(
                width: artSize,
                height: artSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.neonIndigo, AppColors.neonRose],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonIndigo.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(color: Colors.black.withValues(alpha: 0.2)),
                      Icon(
                        Icons.music_note_rounded,
                        size: 22,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _title.isNotEmpty ? _title : 'No track',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: titleSize,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      _artist.isNotEmpty ? _artist : 'Feel the sound',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: artistSize,
                        color: Colors.white.withValues(alpha: 0.5),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (showControls)
                Opacity(
                  opacity: controlsOpacity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MorphMiniButton(
                        icon: Icons.skip_previous_rounded,
                        onTap: () => ref.read(audioHandlerProvider).skipToPrevious(),
                      ),
                      _MorphPlayButton(
                        isPlaying: _isPlaying,
                        progress: showProgress && _duration.inMicroseconds > 0
                            ? (_position.inMicroseconds / _duration.inMicroseconds).clamp(0.0, 1.0)
                            : 0.0,
                        onTap: () {
                          final h = ref.read(audioHandlerProvider);
                          if (_isPlaying) { h.pause(); } else { h.play(); }
                        },
                      ),
                      _MorphMiniButton(
                        icon: Icons.skip_next_rounded,
                        onTap: () => ref.read(audioHandlerProvider).skipToNext(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    final handler = ref.read(audioHandlerProvider);
    return Column(
      children: [
        Spacer(flex: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.x3l),
          child: AlbumArtView(
            imageUrl: 'https://via.placeholder.com/400',
            size: MediaQuery.of(context).size.shortestSide * 0.72,
            mode: _artMode,
            isPlaying: _isPlaying,
            amplitude: _amplitude,
            onModeToggle: () => setState(() {
              _artMode = switch (_artMode) {
                AlbumArtMode.standard => AlbumArtMode.vinyl,
                AlbumArtMode.vinyl => AlbumArtMode.visualizer,
                AlbumArtMode.visualizer => AlbumArtMode.standard,
              };
            }),
          ),
        ),
        Spacer(flex: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.xl),
          child: Column(
            children: [
              Text(
                _title.isNotEmpty ? _title : AudioExtensions.titleFromPath(_filePath),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: Spacing.xs),
              Text(
                _artist.isNotEmpty ? _artist : 'Feel the sound',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  color: const Color(0xFFA6A6A6),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Spacing.xl),
        SeekBar(
          position: _position,
          duration: _duration,
          buffered: _position,
          onSeek: (d) => handler.seek(d),
        ),
        SizedBox(height: Spacing.lg),
        PlayerControls(
          isPlaying: _isPlaying,
          repeatMode: _repeatMode,
          isShuffled: _isShuffled,
          isFavorite: _isFavorite,
          onPlayPause: () {
            if (_isPlaying) {
              handler.pause();
            } else {
              handler.play();
            }
          },
          onNext: () => handler.skipToNext(),
          onPrevious: () => handler.skipToPrevious(),
          onShuffleToggle: () {
            setState(() => _isShuffled = !_isShuffled);
            handler.setShuffle(_isShuffled);
          },
          onRepeatToggle: () {
            setState(() {
              _repeatMode = switch (_repeatMode) {
                RepeatMode.none => RepeatMode.all,
                RepeatMode.all => RepeatMode.one,
                RepeatMode.one => RepeatMode.none,
              };
            });
            handler.changeRepeatMode(_repeatMode);
          },
          onFavoriteToggle: _toggleFavorite,
          onLyricsTap: () {},
          onQueueTap: () {},
          onEqualizerTap: () {},
        ),
        SizedBox(height: Spacing.lg),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.xxl),
          child: _PremiumVolumeBooster(
            volume: _volume,
            onChanged: _onVolumeChanged,
          ),
        ),
        SizedBox(height: Spacing.lg),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.xxl),
          child: _PremiumVolumeBooster(
            volume: _volume,
            onChanged: _onVolumeChanged,
          ),
        ),
        SizedBox(height: Spacing.lg + MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  Future<void> _toggleFavorite() async {
    if (_filePath.isEmpty) return;
    try {
      final repo = await ref.read(musicRepositoryProvider.future);
      await repo.toggleFavorite(_filePath);
      final newState = !_isFavorite;
      setState(() => _isFavorite = newState);
      ref.invalidate(favoritesProvider);
      ref.invalidate(allSongsProvider);
      ref.invalidate(isFavoriteProvider(_filePath));
    } catch (_) {}
  }

  Widget _buildLandscapeLayout() {
    final handler = ref.read(audioHandlerProvider);
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Center(
            child: AlbumArtView(
              imageUrl: 'https://via.placeholder.com/400',
              size: MediaQuery.of(context).size.height * 0.55,
              mode: _artMode,
              isPlaying: _isPlaying,
              amplitude: _amplitude,
              onModeToggle: () => setState(() {
                _artMode = switch (_artMode) {
                  AlbumArtMode.standard => AlbumArtMode.vinyl,
                  AlbumArtMode.vinyl => AlbumArtMode.visualizer,
                  AlbumArtMode.visualizer => AlbumArtMode.standard,
                };
              }),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.fromLTRB(Spacing.xl, 0, Spacing.xxl, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _title.isNotEmpty ? _title : AudioExtensions.titleFromPath(_filePath),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Spacing.xs),
                Text(
                  _artist.isNotEmpty ? _artist : 'Feel the sound',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: const Color(0xFFA6A6A6),
                  ),
                ),
                SizedBox(height: Spacing.xxl),
                SeekBar(
                  position: _position,
                  duration: _duration,
                  buffered: _position,
                  onSeek: (d) => handler.seek(d),
                ),
                SizedBox(height: Spacing.xxl),
                PlayerControls(
                  isPlaying: _isPlaying,
                  repeatMode: _repeatMode,
                  isShuffled: _isShuffled,
                  isFavorite: _isFavorite,
                  onPlayPause: () {
                    if (_isPlaying) {
                      handler.pause();
                    } else {
                      handler.play();
                    }
                  },
                  onNext: () => handler.skipToNext(),
                  onPrevious: () => handler.skipToPrevious(),
                  onShuffleToggle: () {
                    setState(() => _isShuffled = !_isShuffled);
                    handler.setShuffle(_isShuffled);
                  },
                  onRepeatToggle: () {
                    setState(() {
                      _repeatMode = switch (_repeatMode) {
                        RepeatMode.none => RepeatMode.all,
                        RepeatMode.all => RepeatMode.one,
                        RepeatMode.one => RepeatMode.none,
                      };
                    });
                    handler.changeRepeatMode(_repeatMode);
                  },
                  onFavoriteToggle: _toggleFavorite,
                  onLyricsTap: () {},
                  onQueueTap: () {},
                  onEqualizerTap: () {},
                ),
                SizedBox(height: Spacing.lg),
                _PremiumVolumeBooster(
                  volume: _volume,
                  onChanged: _onVolumeChanged,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MorphMiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MorphMiniButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }
}

class _MorphPlayButton extends StatelessWidget {
  final bool isPlaying;
  final double progress;
  final VoidCallback onTap;

  const _MorphPlayButton({
    required this.isPlaying,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 2.5,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.neonIndigo,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.neonIndigo, AppColors.neonRose],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonIndigo.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumVolumeBooster extends StatefulWidget {
  final double volume;
  final ValueChanged<double> onChanged;

  const _PremiumVolumeBooster({required this.volume, required this.onChanged});

  @override
  State<_PremiumVolumeBooster> createState() => _PremiumVolumeBoosterState();
}

class _PremiumVolumeBoosterState extends State<_PremiumVolumeBooster>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (_isBoosted) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PremiumVolumeBooster old) {
    super.didUpdateWidget(old);
    if (_isBoosted && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!_isBoosted && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isBoosted => widget.volume > 1.0;
  double get _displayLevel => (widget.volume / 2.0).clamp(0.0, 1.0);

  void _decrease() =>
      widget.onChanged((widget.volume - 0.05).clamp(0.0, 2.0));
  void _increase() =>
      widget.onChanged((widget.volume + 0.05).clamp(0.0, 2.0));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: _isBoosted
                ? AppColors.neonRose.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _isBoosted
                  ? AppColors.neonRose.withValues(alpha: 0.2 * _pulseAnimation.value)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 4),
              _VolumeButton(
                text: '−',
                onTap: _decrease,
                isBoosted: _isBoosted,
              ),
              SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _displayLevel,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                colors: _isBoosted
                                    ? [AppColors.neonRose, Colors.orangeAccent]
                                    : [AppColors.neonIndigo, AppColors.neonBlue],
                              ),
                              boxShadow: _isBoosted
                                  ? [
                                      BoxShadow(
                                        color: AppColors.neonRose.withValues(alpha: 0.4 * _pulseAnimation.value),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: AppColors.neonIndigo.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isBoosted ? 'BOOST' : 'VOL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _isBoosted
                                ? AppColors.neonRose.withValues(alpha: 0.8 * _pulseAnimation.value)
                                : Colors.white.withValues(alpha: 0.25),
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          widget.volume >= 1.0
                              ? '×${widget.volume.toStringAsFixed(1)}'
                              : '×${widget.volume.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _isBoosted
                                ? AppColors.neonRose
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: Spacing.sm),
              _VolumeButton(
                text: '+',
                onTap: _increase,
                isBoosted: _isBoosted,
              ),
              SizedBox(width: 4),
            ],
          ),
        );
      },
    );
  }
}

class _VolumeButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isBoosted;

  const _VolumeButton({
    required this.text,
    required this.onTap,
    this.isBoosted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isBoosted
                ? [AppColors.neonRose.withValues(alpha: 0.3), AppColors.neonRose.withValues(alpha: 0.15)]
                : [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isBoosted
                ? AppColors.neonRose.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: isBoosted
                  ? AppColors.neonRose
                  : Colors.white.withValues(alpha: 0.7),
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
