import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';
import '../../domain/entities/playback_state.dart';
import '../providers/player_provider.dart';
import '../widgets/album_art_view.dart';
import '../widgets/seek_bar.dart';
import '../widgets/player_controls.dart';

class TabletPlayerPage extends ConsumerStatefulWidget {
  const TabletPlayerPage({super.key});

  @override
  ConsumerState<TabletPlayerPage> createState() => _TabletPlayerPageState();
}

class _TabletPlayerPageState extends ConsumerState<TabletPlayerPage> {
  AlbumArtMode _artMode = AlbumArtMode.standard;
  bool _isPlaying = true;
  double _volume = 0.7;
  final double _amplitude = 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary500.withValues(alpha: 0.1),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Row(
              children: [
                // Left: Album art + visualizer
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AlbumArtView(
                          imageUrl: 'https://via.placeholder.com/400',
                          size: 400,
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
                        SizedBox(height: Spacing.xl),

                        // Mini controls under art
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shuffle_rounded,
                                size: 20, color: AppColors.darkTextTertiary),
                            SizedBox(width: Spacing.xl),
                            Icon(Icons.skip_previous_rounded,
                                size: 28, color: AppColors.darkTextPrimary),
                            SizedBox(width: Spacing.xxl),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.darkTextPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 32,
                                color: AppColors.darkBackground,
                              ),
                            ),
                            SizedBox(width: Spacing.xxl),
                            Icon(Icons.skip_next_rounded,
                                size: 28, color: AppColors.darkTextPrimary),
                            SizedBox(width: Spacing.xl),
                            Icon(Icons.repeat_rounded,
                                size: 20, color: AppColors.darkTextTertiary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Right: Track info + controls + lyrics
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        Spacing.xl, Spacing.xxl, Spacing.xxl, Spacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Track info
                        Text(
                          'Track Title',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.darkTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Spacing.sm),
                        Text(
                          'Artist Name',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                        SizedBox(height: Spacing.xxl),

                        // Progress
                        SeekBar(
                          position: Duration(seconds: 90),
                          duration: Duration(seconds: 240),
                          buffered: Duration(seconds: 180),
                          onSeek: (_) {},
                        ),
                        SizedBox(height: Spacing.xxl),

                        // Controls
                        PlayerControls(
                          isPlaying: _isPlaying,
                          repeatMode: RepeatMode.all,
                          isShuffled: false,
                          isFavorite: false,
                          onPlayPause: () {
                            final handler = ref.read(audioHandlerProvider);
                            if (_isPlaying) {
                              handler.pause();
                            } else {
                              handler.play();
                            }
                            setState(() => _isPlaying = !_isPlaying);
                          },
                          onNext: () =>
                              ref.read(audioHandlerProvider).skipToNext(),
                          onPrevious: () =>
                              ref.read(audioHandlerProvider).skipToPrevious(),
                        ),
                        SizedBox(height: Spacing.xxl),

                        // Volume
                        Padding(
                          padding: EdgeInsets.only(right: Spacing.xxl),
                          child: VolumeSlider(
                            volume: _volume,
                            onChanged: (v) => setState(() => _volume = v),
                          ),
                        ),
                        SizedBox(height: Spacing.xxl),

                        // Divider
                        Divider(color: Colors.white.withValues(alpha: 0.06)),
                        SizedBox(height: Spacing.md),

                        // Lyrics preview
                        Text(
                          'Lyrics appear here on tablet...',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.darkTextTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: Spacing.sm),
                        Text(
                          'The side-by-side layout lets you follow lyrics while viewing album art.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.darkTextTertiary
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
