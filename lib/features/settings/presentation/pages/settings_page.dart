import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/preferences_provider.dart';
import '../../../../shared/widgets/premium_dialogs.dart';
import '../../../../shared/widgets/premium_app_bar.dart';
import '../../../../features/music_engine/presentation/providers/music_engine_provider.dart';
import '../../../debug/music_diagnostics.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    final accent = prefs.accentColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PremiumAppBar(
              scrollController: _scrollController,
              title: 'Settings',
              largeTitle: true,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSection('Appearance', [
                  _buildNavTile(
                    icon: Icons.brightness_6_rounded,
                    title: 'Theme',
                    subtitle: _themeLabel(prefs.themeMode),
                    onTap: () => _showThemeSelector(prefs),
                  ),
                  _buildNavTile(
                    icon: Icons.palette_rounded,
                    title: 'Accent Color',
                    subtitle: accent.name,
                    trailing: _buildColorDot(accent.primary),
                    onTap: () => _showColorSelector(prefs),
                  ),
                  _buildSliderTile(
                    icon: Icons.blur_on_rounded,
                    title: 'Blur Intensity',
                    subtitle: '${(prefs.blurIntensity * 100).round()}%',
                    value: prefs.blurIntensity,
                    onChanged: (v) => ref.read(preferencesProvider.notifier).setBlurIntensity(v),
                  ),
                  _buildSliderTile(
                    icon: Icons.animation_rounded,
                    title: 'Animation Level',
                    subtitle: '${(prefs.animationLevel * 100).round()}%',
                    value: prefs.animationLevel,
                    onChanged: (v) => ref.read(preferencesProvider.notifier).setAnimationLevel(v),
                  ),
                ]),
                const SizedBox(height: 8),
                _buildSection('Playback', [
                  _buildToggleTile(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Crossfade',
                    subtitle: 'Smooth transition between tracks',
                    value: prefs.crossfadeEnabled,
                    onChanged: (v) => ref.read(preferencesProvider.notifier).setCrossfadeEnabled(v),
                  ),
                  if (prefs.crossfadeEnabled)
                    _buildSliderTile(
                      icon: Icons.timer_rounded,
                      title: 'Crossfade Duration',
                      subtitle: '${prefs.crossfadeDuration.round()} seconds',
                      value: prefs.crossfadeDuration,
                      min: 1,
                      max: 12,
                      divisions: 11,
                      onChanged: (v) => ref.read(preferencesProvider.notifier).setCrossfadeDuration(v),
                    ),
                  _buildToggleTile(
                    icon: Icons.music_note_rounded,
                    title: 'Gapless Playback',
                    subtitle: 'Seamless transition between tracks',
                    value: prefs.gaplessPlayback,
                    onChanged: (v) => ref.read(preferencesProvider.notifier).setGaplessPlayback(v),
                  ),
                  _buildToggleTile(
                    icon: Icons.play_circle_rounded,
                    title: 'Auto-play',
                    subtitle: 'Automatically play music on app start',
                    value: prefs.autoPlay,
                    onChanged: (v) => ref.read(preferencesProvider.notifier).setAutoPlay(v),
                  ),
                  _buildToggleTile(
                    icon: Icons.bookmark_rounded,
                    title: 'Remember Position',
                    subtitle: 'Resume from where you left off',
                    value: prefs.rememberPosition,
                    onChanged: (v) => ref.read(preferencesProvider.notifier).setRememberPosition(v),
                  ),
                ]),
                const SizedBox(height: 8),
                _buildSection('Library', [
                  _buildNavTile(
                    icon: Icons.refresh_rounded,
                    title: 'Rescan Music',
                    subtitle: 'Scan device for new audio files',
                    onTap: () {
                      ref.read(scanTriggerProvider.notifier).state++;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Rescanning music library...'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  _buildNavTile(
                    icon: Icons.cleaning_services_rounded,
                    title: 'Clear Cache',
                    subtitle: 'Free up storage space',
                    onTap: () => _clearCache(),
                  ),
                  _buildNavTile(
                    icon: Icons.storage_rounded,
                    title: 'Storage Info',
                    subtitle: 'View storage details',
                    onTap: () => _showStorageInfo(),
                  ),
                ]),
                const SizedBox(height: 8),
                _buildSection('About', [
                  _buildInfoTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    subtitle: '1.0.0',
                  ),
                  _buildNavTile(
                    icon: Icons.description_rounded,
                    title: 'Open Source Licenses',
                    subtitle: 'View third-party licenses',
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'BITOO',
                      applicationVersion: '1.0.0',
                      applicationIcon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [accent.primary, accent.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                  _buildNavTile(
                    icon: Icons.bug_report_rounded,
                    title: 'Diagnostic Audio',
                    subtitle: 'Test all audio files',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MusicDiagnosticsPage()),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.dark => 'Dark',
      AppThemeMode.light => 'Light',
      AppThemeMode.amoled => 'AMOLED Black',
      AppThemeMode.system => 'System Default',
    };
  }

  void _showThemeSelector(AppPreferences prefs) {
    PremiumBottomSheet.show(
      context,
      builder: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(Icons.brightness_6_rounded, size: 18, color: AppColors.neonIndigo),
                SizedBox(width: 8),
                Text(
                  'Choose Theme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
          ...AppThemeMode.values.map((mode) {
            final isSelected = prefs.themeMode == mode;
            return GestureDetector(
              onTap: () {
                ref.read(preferencesProvider.notifier).setThemeMode(mode);
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.neonIndigo.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _themeIcon(mode),
                      size: 20,
                      color: isSelected ? AppColors.neonIndigo : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _themeLabel(mode),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.neonIndigo : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_rounded, size: 18, color: AppColors.neonIndigo),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  IconData _themeIcon(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.dark => Icons.dark_mode_rounded,
      AppThemeMode.light => Icons.light_mode_rounded,
      AppThemeMode.amoled => Icons.nightlight_round_rounded,
      AppThemeMode.system => Icons.settings_brightness_rounded,
    };
  }

  void _showColorSelector(AppPreferences prefs) {
    PremiumBottomSheet.show(
      context,
      builder: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(Icons.palette_rounded, size: 18, color: AppColors.neonIndigo),
                SizedBox(width: 8),
                Text(
                  'Accent Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: accentColors.length,
              itemBuilder: (context, i) {
                final color = accentColors[i];
                final isSelected = prefs.accentColor.name == color.name;
                return GestureDetector(
                  onTap: () {
                    ref.read(preferencesProvider.notifier).setAccentColor(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? color.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.primary,
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? Icon(Icons.check_rounded, size: 18, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await PremiumConfirmDialog.show(
      context,
      title: 'Clear Cache',
      message: 'This will remove all cached artwork and temporary files.',
      confirmLabel: 'Clear',
      icon: Icons.cleaning_services_rounded,
    );
    if (confirmed == true) {
      try {
        final repo = await ref.read(musicRepositoryProvider.future);
        final cleared = await repo.clearArtworkCache();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cache cleared: ${(cleared / 1024 / 1024).toStringAsFixed(1)} MB freed'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  Future<void> _showStorageInfo() async {
    try {
      final stats = await ref.read(storageStatsProvider.future);
      if (!mounted) return;
      PremiumBottomSheet.show(
        context,
        builder: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.storage_rounded, size: 18, color: AppColors.neonIndigo),
                  SizedBox(width: 8),
                  Text(
                    'Storage Info',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06), height: 1),
            _storageTile('Songs', '${stats['songs'] ?? 0}'),
            _storageTile('Albums', '${stats['albums'] ?? 0}'),
            _storageTile('Artists', '${stats['artists'] ?? 0}'),
            _storageTile(
              'Cache Size',
              _formatBytes(stats['cacheSizeBytes'] ?? 0),
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    } catch (_) {}
  }

  Widget _storageTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2), width: 1),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(children.length, (i) {
              return Column(
                children: [
                  if (i > 0)
                    Divider(height: 0.5, color: Theme.of(context).dividerTheme.color),
                  children[i],
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.neonIndigo.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.neonIndigo),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.neonIndigo,
          activeTrackColor: AppColors.neonIndigo.withValues(alpha: 0.4),
          inactiveThumbColor: Theme.of(context).colorScheme.onSurfaceVariant,
          inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12,
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    double min = 0,
    double max = 1,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.neonIndigo.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.neonIndigo),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.neonIndigo,
                inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12,
                trackHeight: 3,
                thumbColor: Theme.of(context).colorScheme.primary,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayColor: AppColors.neonIndigo.withValues(alpha: 0.12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.neonIndigo.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.neonIndigo),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.neonIndigo.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.neonIndigo),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
