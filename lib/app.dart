import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/color_schemes.dart';
import 'core/theme/tokens.dart';
import 'features/permissions/presentation/pages/permission_welcome_page.dart';
import 'features/permissions/presentation/pages/permission_request_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/music_engine/presentation/providers/music_engine_provider.dart';
import 'features/music_engine/data/models/scan_progress.dart';
import 'features/music_engine/core/audio_extensions.dart';
import 'features/player/presentation/providers/player_provider.dart';
import 'features/player/presentation/pages/fullscreen_player_page.dart';
import 'shared/widgets/premium_bottom_nav.dart';

class BitooApp extends ConsumerWidget {
  const BitooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'BITOO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
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
        backgroundColor: AppColors.darkBackground,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary500),
        ),
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

class _MainShellState extends ConsumerState<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  StreamSubscription? _playbackSub;
  StreamSubscription? _itemSub;
  String _trackPath = '';
  String _trackTitle = '';
  String _trackArtist = '';
  bool _isPlaying = false;

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
        });
      }
    });
    _playbackSub = handler.playbackState.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(scanTriggerProvider.notifier).state++;
    }
  }

  void _openPlayer() {
    if (_trackPath.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenPlayerPage(
          filePath: _trackPath,
          title: _trackTitle,
          artist: _trackArtist,
        ),
      ),
    );
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

    final pages = [
      const HomePage(),
      const Center(child: Text('Explore', style: TextStyle(color: Colors.white54))),
      const Center(child: Text('Library', style: TextStyle(color: Colors.white54))),
      const Center(child: Text('Search', style: TextStyle(color: Colors.white54))),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: _trackPath.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MiniPlayerBar(
                  title: _trackTitle,
                  artist: _trackArtist,
                  isPlaying: _isPlaying,
                  onPlayPause: () {
                    final handler = ref.read(audioHandlerProvider);
                    if (_isPlaying) {
                      handler.pause();
                    } else {
                      handler.play();
                    }
                  },
                  onTap: _openPlayer,
                ),
                PremiumBottomNav(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                ),
              ],
            )
          : PremiumBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  final String title;
  final String artist;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onTap;

  const _MiniPlayerBar({
    required this.title,
    required this.artist,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceLight,
          border: Border(
            top: BorderSide(color: AppColors.darkTextTertiary.withValues(alpha: 0.15), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: Spacing.md),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.music_note_rounded, size: 20, color: AppColors.darkTextTertiary),
            ),
            SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(color: AppColors.darkTextPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (artist.isNotEmpty)
                    Text(
                      artist,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.darkTextTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onPlayPause,
              child: Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.only(right: Spacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 22,
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
