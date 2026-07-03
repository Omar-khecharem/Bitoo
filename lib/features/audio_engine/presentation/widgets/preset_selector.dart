import 'package:flutter/material.dart';
import '../../domain/entities/preset_config.dart';

class PresetSelector extends StatelessWidget {
  final String activePreset;
  final void Function(PresetConfig preset)? onPresetSelected;
  final bool isEnabled;

  const PresetSelector({
    super.key,
    required this.activePreset,
    this.onPresetSelected,
    this.isEnabled = true,
  });

  static const _presetIcons = {
    'flat': Icons.graphic_eq_rounded,
    'rock': Icons.music_note_rounded,
    'pop': Icons.headphones_rounded,
    'jazz': Icons.piano_rounded,
    'classic': Icons.music_note_rounded,
    'electronic': Icons.waves_rounded,
    'podcast': Icons.mic_rounded,
    'movie': Icons.movie_rounded,
    'gaming': Icons.sports_esports_rounded,
    'voice': Icons.record_voice_over_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: PresetConfig.presetNames.map((name) {
          final preset = PresetConfig.presets[name]!;
          final isActive = name == activePreset;
          final icon = _presetIcons[name] ?? Icons.graphic_eq_rounded;

          return Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: isEnabled ? () => onPresetSelected?.call(preset) : null,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                width: 64,
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: isActive
                          ? const Color(0xFF8B5CF6)
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 4),
                    Text(
                      preset.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive
                            ? const Color(0xFF8B5CF6)
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
