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
                activeColor: Theme.of(context).colorScheme.tertiary,
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
            gradient: AppGradients.indigoToRose,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.neonIndigo.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.neonRose.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 4,
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
              color: Theme.of(context).colorScheme.onSurface,
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
        child: Icon(widget.icon, size: 28, color: Theme.of(context).colorScheme.onSurface),
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
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.shuffle_rounded,
          size: 22,
          color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
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
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 22,
              color: _isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
            ),
            if (mode == RepeatMode.one) ...[
              SizedBox(width: 2),
              Text(
                '1',
                style: AppTypography.labelSmall.copyWith(
                  color: Theme.of(context).colorScheme.primary,
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

class _SecondaryButton extends StatefulWidget {
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
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_SecondaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.icon == Icons.favorite_rounded && oldWidget.icon != Icons.favorite_rounded) {
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
    return GestureDetector(
      onTap: () {
        if (widget.icon == Icons.favorite_outline_rounded ||
            widget.icon == Icons.favorite_rounded) {
          _pulseController.forward().then((_) => _pulseController.reverse());
        }
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.isActive
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.15))
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: widget.size * 0.55,
                color: widget.isActive
                    ? (widget.activeColor ?? Theme.of(context).colorScheme.primary)
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          );
        },
      ),
    );
  }
}
