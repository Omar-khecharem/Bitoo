import 'package:flutter/material.dart';
import '../../domain/entities/audio_engine_state.dart';
import '../../domain/entities/preset_config.dart';
import 'equalizer_visualizer.dart';
import 'preset_selector.dart';

class AudioEffectsPanel extends StatefulWidget {
  final AudioEngineReady state;
  final void Function(int index, double value)? onBandChanged;
  final void Function(PresetConfig preset)? onPresetSelected;
  final void Function(double value)? onBassChanged;
  final void Function(double value)? onVirtualizerChanged;
  final void Function(double value)? onCrossfadeChanged;
  final void Function(bool value)? onEqualizerToggled;
  final void Function(bool value)? onBassToggled;
  final void Function(bool value)? onVirtualizerToggled;
  final void Function(bool value)? onVolumeNormalizationToggled;
  final void Function(bool value)? onGaplessToggled;
  final void Function(HiResMode mode)? onHiResModeChanged;
  final VoidCallback? onReset;
  final VoidCallback? onClose;

  const AudioEffectsPanel({
    super.key,
    required this.state,
    this.onBandChanged,
    this.onPresetSelected,
    this.onBassChanged,
    this.onVirtualizerChanged,
    this.onCrossfadeChanged,
    this.onEqualizerToggled,
    this.onBassToggled,
    this.onVirtualizerToggled,
    this.onVolumeNormalizationToggled,
    this.onGaplessToggled,
    this.onHiResModeChanged,
    this.onReset,
    this.onClose,
  });

  @override
  State<AudioEffectsPanel> createState() => _AudioEffectsPanelState();
}

class _AudioEffectsPanelState extends State<AudioEffectsPanel> {
  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      height: isLandscape
          ? MediaQuery.of(context).size.height * 0.9
          : MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C26),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
              child: Column(
                children: [
                  _buildEqualizerSection(s),
                  _buildEffectToggles(s),
                  _buildAdvancedSection(s),
                  if (widget.onReset != null) _buildResetButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Container(
        width: 40, height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 16, 12),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, size: 20, color: Colors.white.withValues(alpha: 0.9)),
          SizedBox(width: 8),
          Text('Audio Effects', style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white,
          )),
          Spacer(),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 18, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEqualizerSection(AudioEngineReady s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.graphic_eq_rounded, size: 18, color: Colors.white.withValues(alpha: 0.5)),
                  SizedBox(width: 8),
                  Text('Equalizer', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.9),
                  )),
                ],
              ),
              Switch(
                value: s.eqEnabled,
                onChanged: widget.onEqualizerToggled,
                activeColor: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ),
        if (s.eqEnabled) ...[
          PresetSelector(
            activePreset: s.activePreset,
            isEnabled: s.eqEnabled,
            onPresetSelected: widget.onPresetSelected,
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: EqualizerVisualizer(
              bands: s.eqBands,
              isEnabled: s.eqEnabled,
              onBandChanged: widget.onBandChanged,
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: EQFrequencyLabels(isEnabled: s.eqEnabled),
          ),
        ],
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEffectToggles(AudioEngineReady s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _EffectSliderTile(
            icon: Icons.speaker_rounded,
            label: 'Bass Boost',
            value: s.bassBoostStrength / 1000.0,
            displayValue: '${(s.bassBoostStrength / 10).round()}%',
            enabled: s.bassBoostEnabled,
            onToggle: widget.onBassToggled,
            onChanged: widget.onBassChanged,
          ),
          SizedBox(height: 16),
          _EffectSliderTile(
            icon: Icons.surround_sound_rounded,
            label: 'Virtualizer (3D Audio)',
            value: s.virtualizerStrength / 1000.0,
            displayValue: '${(s.virtualizerStrength / 10).round()}%',
            enabled: s.virtualizerEnabled,
            onToggle: widget.onVirtualizerToggled,
            onChanged: widget.onVirtualizerChanged,
          ),
          SizedBox(height: 16),
          if (s.crossfadeDurationSeconds > 0 || s.gaplessEnabled)
            _EffectSliderTile(
              icon: Icons.swap_horiz_rounded,
              label: 'Crossfade',
              value: s.crossfadeDurationSeconds / 12.0,
              displayValue: '${s.crossfadeDurationSeconds.toStringAsFixed(0)}s',
              enabled: true,
              onToggle: null,
              onChanged: widget.onCrossfadeChanged,
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(AudioEngineReady s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Advanced', style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.5),
          )),
          SizedBox(height: 12),
          _ToggleTile(
            icon: Icons.volume_up_rounded,
            label: 'Volume Normalization',
            subtitle: 'Target -14 LUFS',
            value: s.volumeNormalizationEnabled,
            onChanged: widget.onVolumeNormalizationToggled,
          ),
          SizedBox(height: 8),
          _ToggleTile(
            icon: Icons.skip_next_rounded,
            label: 'Gapless Playback',
            subtitle: 'Zero-delay track transitions',
            value: s.gaplessEnabled,
            onChanged: widget.onGaplessToggled,
          ),
          if (s.hiResMode != HiResMode.off) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.high_quality_rounded, size: 18, color: Colors.white.withValues(alpha: 0.5)),
                SizedBox(width: 8),
                Text('Hi-Res Output', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.9),
                )),
                Spacer(),
                DropdownButton<HiResMode>(
                  value: s.hiResMode,
                  dropdownColor: const Color(0xFF262633),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  underline: SizedBox(),
                  items: HiResMode.values.map((mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(mode.label),
                  )).toList(),
                  onChanged: (v) => widget.onHiResModeChanged?.call(v!),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: TextButton.icon(
        onPressed: widget.onReset,
        icon: Icon(Icons.restart_alt_rounded, size: 16),
        label: Text('Reset to Default'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _EffectSliderTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final String displayValue;
  final bool enabled;
  final void Function(bool)? onToggle;
  final void Function(double)? onChanged;

  const _EffectSliderTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.displayValue,
    required this.enabled,
    this.onToggle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.white.withValues(alpha: enabled ? 0.7 : 0.3)),
            SizedBox(width: 8),
            Expanded(
              child: Text(label, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: enabled ? 0.9 : 0.4),
              )),
            ),
            if (onToggle != null)
              SizedBox(
                height: 24,
                child: Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeColor: const Color(0xFF8B5CF6),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            SizedBox(width: 8),
            Text(displayValue, style: TextStyle(
              fontSize: 13, color: Colors.white.withValues(alpha: enabled ? 0.5 : 0.3),
            )),
          ],
        ),
        SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: enabled ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.1),
            inactiveTrackColor: Colors.white.withValues(alpha: enabled ? 0.1 : 0.05),
            trackHeight: 3,
            thumbColor: enabled ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.2),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
          ),
          child: Slider(
            value: value.clamp(0.0, 1.0),
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final void Function(bool)? onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: value
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: value
                ? const Color(0xFF8B5CF6)
                : Colors.white.withValues(alpha: 0.4)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: value ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.8),
                  )),
                  Text(subtitle, style: TextStyle(
                    fontSize: 11, color: Colors.white.withValues(alpha: 0.3),
                  )),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF8B5CF6),
            ),
          ],
        ),
      ),
    );
  }
}
