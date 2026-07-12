import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/color_schemes.dart';
import 'core/theme/preferences_provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/animations/curves.dart';
import 'features/permissions/presentation/pages/permission_welcome_page.dart';
import 'features/permissions/presentation/pages/permission_request_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/music_engine/presentation/providers/music_engine_provider.dart';
import 'features/music_engine/data/models/scan_progress.dart';
import 'features/music_engine/core/audio_extensions.dart';
import 'features/player/presentation/providers/player_provider.dart';
import 'features/player/presentation/pages/fullscreen_player_page.dart';

class BitooApp extends ConsumerStatefulWidget {
  const BitooApp({super.key});

  @override
  ConsumerState<BitooApp> createState() => _BitooAppState();
}

class _BitooAppState extends ConsumerState<BitooApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    await ref.read(preferencesProvider.notifier).init();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final darkTheme = ref.watch(appThemeDataProvider);
    final lightTheme = ref.watch(appLightThemeDataProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'BITOO',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const PermissionFlow(),
    );
  }
}

class PermissionFlow extends ConsumerStatefulWidget {
  const PermissionFlow({super.key});

  @override
  ConsumerState<PermissionFlow> createState() => _PermissionFlowState();
}

class _PermissionFlowState extends ConsumerState<PermissionFlow> {
  bool _checking = true;
  bool _showWelcome = true;
  bool _showRequests = false;
  bool _showMainApp = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final repo = await ref.read(musicRepositoryProvider.future);
      final hasPerm = await repo.hasPermission();
      if (hasPerm && mounted) {
        setState(() {
          _showMainApp = true;
          _checking = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_showMainApp) {
      return const MainShell();
    }

    if (_showWelcome) {
      return PermissionWelcomePage(
        onContinue: () {
          setState(() {
            _showWelcome = false;
            _showRequests = true;
          });
        },
      );
    }

    if (_showRequests) {
      return PermissionRequestPage(
        onComplete: () {
          setState(() {
            _showRequests = false;
            _showMainApp = true;
          });
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  StreamSubscription? _playbackSub;
  StreamSubscription? _itemSub;
  String _trackPath = '';
  String _trackTitle = '';
  String _trackArtist = '';
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  double get _progress => _duration.inMicroseconds > 0
      ? (_position.inMicroseconds / _duration.inMicroseconds).clamp(0.0, 1.0)
      : 0.0;
  OverlayEntry? _playerOverlay;
  bool _isOpeningPlayer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscribeToPlayer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playbackSub?.cancel();
    _itemSub?.cancel();
    _playerOverlay?.remove();
    super.dispose();
  }

  void _subscribeToPlayer() {
    final handler = ref.read(audioHandlerProvider);
    _itemSub = handler.mediaItem.listen((item) {
      if (item != null && mounted) {
        setState(() {
          _trackPath = item.id;
          _trackTitle = AudioExtensions.titleFromPath(item.id);
          final a = item.artist ?? '';
          _trackArtist = a.isNotEmpty && a != 'Unknown Artist' ? a : '';
          _duration = item.duration ?? Duration.zero;
        });
      }
    });
    _playbackSub = handler.playbackState.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _position = state.position;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(scanTriggerProvider.notifier).state++;
    }
  }

  void _openPlayer() {
    if (_trackPath.isEmpty || _isOpeningPlayer) return;
    _isOpeningPlayer = true;
    _playerOverlay?.remove();
    final overlay = OverlayEntry(
      builder: (_) => _PlayerOverlayTransition(
        key: const ValueKey('player_overlay'),
        onDismissed: () {
          _playerOverlay?.remove();
          _playerOverlay = null;
          _isOpeningPlayer = false;
          setState(() {});
        },
        builder: (t, ctrl) => FullscreenPlayerPage(
          filePath: _trackPath,
          title: _trackTitle,
          artist: _trackArtist,
          expandProgress: t,
          overlayController: ctrl,
        ),
      ),
    );
    _playerOverlay = overlay;
    Overlay.of(context).insert(overlay);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ScanProgress>>(scanProgressProvider, (_, next) {
      next.whenData((progress) {
        if (progress.isComplete) {
          ref.invalidate(allSongsProvider);
          ref.read(homeFeedProvider.notifier).loadFeed();
        }
      });
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const HomePage(),
      bottomNavigationBar: _trackPath.isNotEmpty && _playerOverlay == null
          ? _PremiumMiniPlayerBar(
              title: _trackTitle,
              artist: _trackArtist,
              isPlaying: _isPlaying,
              progress: _progress,
              onPlayPause: () {
                final handler = ref.read(audioHandlerProvider);
                if (_isPlaying) {
                  handler.pause();
                } else {
                  handler.play();
                }
              },
              onNext: () => ref.read(audioHandlerProvider).skipToNext(),
              onPrevious: () => ref.read(audioHandlerProvider).skipToPrevious(),
              onTap: _openPlayer,
            )
          : null,
    );
  }
}

class _PremiumMiniPlayerBar extends StatefulWidget {
  final String title;
  final String artist;
  final bool isPlaying;
  final double progress;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onTap;

  const _PremiumMiniPlayerBar({
    required this.title,
    required this.artist,
    required this.isPlaying,
    required this.progress,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onTap,
  });

  @override
  State<_PremiumMiniPlayerBar> createState() => _PremiumMiniPlayerBarState();
}

class _PremiumMiniPlayerBarState extends State<_PremiumMiniPlayerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(_PremiumMiniPlayerBar old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !old.isPlaying) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // iOS-style progress bar at top edge
              SizedBox(
                height: 2,
                child: Row(
                  children: [
                    FractionallySizedBox(
                      widthFactor: widget.progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cs.primary, cs.secondary],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
                  child: Row(
                    children: [
                      // Album art (rounded square like Apple Music)
                      Hero(
                        tag: 'mini_art',
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withValues(alpha: 0.7),
                                cs.secondary.withValues(alpha: 0.5)
                              ],
                            ),
                          ),
                          child: Icon(Icons.music_note_rounded,
                              size: 22,
                              color: cs.onPrimary.withValues(alpha: 0.7)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Track info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title.isNotEmpty
                                  ? widget.title
                                  : 'No track',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.artist.isNotEmpty
                                  ? widget.artist
                                  : 'Feel the sound',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Apple Music-style controls
                      _SquishyIconButton(
                        icon: Icons.skip_previous_rounded,
                        size: 22,
                        color: cs.onSurface.withValues(alpha: 0.6),
                        onTap: widget.onPrevious,
                      ),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          final scale = 1.0 + _pulseController.value * 0.05;
                          return Transform.scale(
                            scale: scale,
                            child: GestureDetector(
                              onTap: widget.onPlayPause,
                              child: Container(
                                width: 44,
                                height: 44,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [cs.primary, cs.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  widget.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 22,
                                  color: cs.onPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      _SquishyIconButton(
                        icon: Icons.skip_next_rounded,
                        size: 22,
                        color: cs.onSurface.withValues(alpha: 0.6),
                        onTap: widget.onNext,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquishyIconButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;

  const _SquishyIconButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SquishyIconButton> createState() => _SquishyIconButtonState();
}

class _SquishyIconButtonState extends State<_SquishyIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _anim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => Transform.scale(
          scale: _anim.value,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(widget.icon, size: widget.size, color: widget.color),
          ),
        ),
      ),
    );
  }
}

class _PlayerOverlayTransition extends StatefulWidget {
  final Widget Function(double expandProgress, AnimationController controller)
      builder;
  final VoidCallback onDismissed;

  const _PlayerOverlayTransition({
    super.key,
    required this.builder,
    required this.onDismissed,
  });

  @override
  State<_PlayerOverlayTransition> createState() =>
      _PlayerOverlayTransitionState();
}

class _PlayerOverlayTransitionState extends State<_PlayerOverlayTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const double _dismissThreshold = 0.25;
  static const double _restoreThreshold = 0.35;
  static const double _minVelocity = 300.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationCurves.transitionDuration.modal,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleDragEnd(double velocity) {
    final value = _controller.value;
    final absVel = velocity.abs();

    if (value < _dismissThreshold) {
      _reverseWithVelocity(velocity);
    } else if (value > _restoreThreshold) {
      _forwardWithVelocity(velocity);
    } else if (absVel > _minVelocity) {
      if (velocity > 0) {
        _reverseWithVelocity(velocity);
      } else {
        _forwardWithVelocity(velocity);
      }
    } else {
      _controller.forward();
    }
  }

  void _reverseWithVelocity(double velocity) {
    _controller.reverse();
  }

  void _forwardWithVelocity(double velocity) {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value.clamp(0.0, 1.0);
        final screenHeight = MediaQuery.of(context).size.height;
        return Stack(
          children: [
            if (t > 0)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5 * t),
                ),
              ),
            SizedBox(
              height: screenHeight,
              child: widget.builder(t, _controller),
            ),
          ],
        );
      },
    );
  }
}
