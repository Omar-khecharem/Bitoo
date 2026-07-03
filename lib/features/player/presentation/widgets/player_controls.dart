import 'package:flutter/material.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';
import '../../domain/entities/playback_state.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.repeatMode,
    required this.isShuffled,
    required this.isFavorite,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onShuffleToggle,
    this.onRepeatToggle,
    this.onFavoriteToggle,
    this.onLyricsTap,
    this.onQueueTap,
    this.onEqualizerTap,
  });

  final bool isPlaying;
  final RepeatMode repeatMode;
  final bool isShuffled;
  final bool isFavorite;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onShuffleToggle;
  final VoidCallback? onRepeatToggle;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onLyricsTap;
  final VoidCallback? onQueueTap;
  final VoidCallback? onEqualizerTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main transport controls
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ShuffleButton(isActive: isShuffled, onTap: onShuffleToggle),
              SizedBox(width: Spacing.xl),
              _SkipButton(
                icon: Icons.skip_previous_rounded,
                onTap: onPrevious,
              ),
              SizedBox(width: Spacing.xl),
              _PlayPauseButton(
                isPlaying: isPlaying,
                onTap: onPlayPause,
              ),
              SizedBox(width: Spacing.xl),
              _SkipButton(
                icon: Icons.skip_next_rounded,
                onTap: onNext,
              ),
              SizedBox(width: Spacing.xl),
              _RepeatButton(mode: repeatMode, onTap: onRepeatToggle),
            ],
          ),
        ),

        SizedBox(height: Spacing.xl),

        // Secondary controls
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.xxl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SecondaryButton(
                icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                isActive: isFavorite,
                activeColor: AppColors.tertiary500,
                onTap: onFavoriteToggle,
                size: 40,
              ),
              _SecondaryButton(
                icon: Icons.lyrics_rounded,
                isActive: false,
                onTap: onLyricsTap,
                size: 40,
              ),
              _SecondaryButton(
                icon: Icons.queue_music_rounded,
                isActive: false,
                onTap: onQueueTap,
                size: 40,
              ),
              _SecondaryButton(
                icon: Icons.tune_rounded,
                isActive: false,
                onTap: onEqualizerTap,
                size: 40,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatefulWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    this.onTap,
  });

  final bool isPlaying;
  final VoidCallback? onTap;

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
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
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.darkTextPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.darkTextPrimary.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: AppDurations.micro,
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              widget.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              key: ValueKey(widget.isPlaying),
              size: 36,
              color: AppColors.darkBackground,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends StatefulWidget {
  const _SkipButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<_SkipButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Icon(widget.icon, size: 32, color: AppColors.darkTextPrimary),
      ),
    );
  }
}

class _ShuffleButton extends StatelessWidget {
  const _ShuffleButton({required this.isActive, this.onTap});

  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.standard,
        curve: Curves.easeOut,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary500.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.shuffle_rounded,
          size: 22,
          color: isActive ? AppColors.primary500 : AppColors.darkTextTertiary,
        ),
      ),
    );
  }
}

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({required this.mode, this.onTap});

  final RepeatMode mode;
  final VoidCallback? onTap;

  IconData get _icon {
    return switch (mode) {
      RepeatMode.none => Icons.repeat_rounded,
      RepeatMode.one => Icons.repeat_one_rounded,
      RepeatMode.all => Icons.repeat_rounded,
    };
  }

  bool get _isActive => mode != RepeatMode.none;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.standard,
        curve: Curves.easeOut,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isActive
              ? AppColors.primary500.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 22,
              color: _isActive ? AppColors.primary500 : AppColors.darkTextTertiary,
            ),
            if (mode == RepeatMode.one) ...[
              SizedBox(width: 2),
              Text(
                '1',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.isActive,
    this.activeColor,
    this.onTap,
    this.size = 40,
  });

  final IconData icon;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: AppColors.glassOpacityMedium),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: size * 0.55,
          color: isActive
              ? (activeColor ?? AppColors.primary500)
              : AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}
