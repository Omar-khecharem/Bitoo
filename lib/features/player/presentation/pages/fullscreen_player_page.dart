import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';
import '../../../music_engine/core/audio_extensions.dart';
import '../../domain/entities/playback_state.dart';
import '../widgets/album_art_view.dart';
import '../widgets/seek_bar.dart';
import '../widgets/player_controls.dart';
import '../providers/player_provider.dart';

class FullscreenPlayerPage extends ConsumerStatefulWidget {
  final String filePath;
  final String title;
  final String artist;

  const FullscreenPlayerPage({
    super.key,
    required this.filePath,
    this.title = '',
    this.artist = '',
  });

  @override
  ConsumerState<FullscreenPlayerPage> createState() => _FullscreenPlayerPageState();
}

class _FullscreenPlayerPageState extends ConsumerState<FullscreenPlayerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;

  // Gesture state
  Offset _dragStart = Offset.zero;
  Offset _dragOffset = Offset.zero;

  // Player state
  AlbumArtMode _artMode = AlbumArtMode.standard;
  bool _isPlaying = true;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.7;
  double get _amplitude => 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
    _pageController = AnimationController(
      vsync: this,
      duration: AppDurations.complex,
    )..forward();
    _pageAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    _initPlayer();
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
      if (item?.duration != null && mounted) {
        setState(() => _duration = item!.duration!);
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _closePlayer() {
    _pageController.reverse().then((_) => Navigator.of(context).pop());
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = details.globalPosition - _dragStart;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset.dy > 100 || details.primaryVelocity! > 500) {
      _closePlayer();
    } else {
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! > 300) {
      // Previous track
    } else if (details.primaryVelocity! < -300) {
      // Next track
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _pageAnimation.value) * 200 + _dragOffset.dy),
          child: Opacity(
            opacity: _pageAnimation.value,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: _buildContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkBackground,
            const Color(0xFF0A0A1A),
            AppColors.darkBackground,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
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
          SafeArea(
            child: GestureDetector(
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: isLandscape
                  ? _buildLandscapeLayout()
                  : _buildPortraitLayout(),
            ),
          ),
          Positioned(
            top: mediaQuery.padding.top + 8,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _closePlayer,
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
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
                AudioExtensions.titleFromPath(widget.filePath),
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: Spacing.xs),
              if (widget.artist.isNotEmpty)
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    widget.artist,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
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
          repeatMode: RepeatMode.all,
          isShuffled: false,
          isFavorite: false,
          onPlayPause: () {
            if (_isPlaying) {
              handler.pause();
            } else {
              handler.play();
            }
          },
          onNext: () {},
          onPrevious: () {},
          onShuffleToggle: () {},
          onRepeatToggle: () {},
          onFavoriteToggle: () {},
          onLyricsTap: () {},
          onQueueTap: () {},
          onEqualizerTap: () {},
        ),
        SizedBox(height: Spacing.xl),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.xxl),
          child: _VolumeSlider(
            volume: _volume,
            onChanged: (v) => setState(() => _volume = v),
          ),
        ),
        SizedBox(height: Spacing.xl + MediaQuery.of(context).padding.bottom),
      ],
    );
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
                  AudioExtensions.titleFromPath(widget.filePath),
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Spacing.xs),
                if (widget.artist.isNotEmpty)
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      widget.artist,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
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
                  repeatMode: RepeatMode.all,
                  isShuffled: false,
                  isFavorite: false,
                  onPlayPause: () {
                    if (_isPlaying) {
                      handler.pause();
                    } else {
                      handler.play();
                    }
                  },
                  onNext: () {},
                  onPrevious: () {},
                  onShuffleToggle: () {},
                  onRepeatToggle: () {},
                  onFavoriteToggle: () {},
                  onLyricsTap: () {},
                  onQueueTap: () {},
                  onEqualizerTap: () {},
                ),
                SizedBox(height: Spacing.xl),
                _VolumeSlider(
                  volume: _volume,
                  onChanged: (v) => setState(() => _volume = v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onChanged;

  const _VolumeSlider({required this.volume, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.volume_down_rounded, color: Colors.white.withValues(alpha: 0.4), size: 18),
        Expanded(
          child: Slider(
            value: volume,
            min: 0.0,
            max: 1.0,
            activeColor: AppColors.primary500,
            inactiveColor: Colors.white.withValues(alpha: 0.1),
            onChanged: onChanged,
          ),
        ),
        Icon(Icons.volume_up_rounded, color: Colors.white.withValues(alpha: 0.4), size: 18),
      ],
    );
  }
}
