import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'app_theme.dart';

enum AppThemeMode { dark, light, amoled, system }

class AppPreferences {
  final AppThemeMode themeMode;
  final AccentColor accentColor;
  final double blurIntensity;
  final double animationLevel;
  final bool crossfadeEnabled;
  final double crossfadeDuration;
  final bool gaplessPlayback;
  final bool autoPlay;
  final bool rememberPosition;

  const AppPreferences({
    this.themeMode = AppThemeMode.dark,
    this.accentColor = AccentColor.festival,
    this.blurIntensity = 1.0,
    this.animationLevel = 1.0,
    this.crossfadeEnabled = false,
    this.crossfadeDuration = 3.0,
    this.gaplessPlayback = true,
    this.autoPlay = false,
    this.rememberPosition = true,
  });

  AppPreferences copyWith({
    AppThemeMode? themeMode,
    AccentColor? accentColor,
    double? blurIntensity,
    double? animationLevel,
    bool? crossfadeEnabled,
    double? crossfadeDuration,
    bool? gaplessPlayback,
    bool? autoPlay,
    bool? rememberPosition,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      blurIntensity: blurIntensity ?? this.blurIntensity,
      animationLevel: animationLevel ?? this.animationLevel,
      crossfadeEnabled: crossfadeEnabled ?? this.crossfadeEnabled,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      autoPlay: autoPlay ?? this.autoPlay,
      rememberPosition: rememberPosition ?? this.rememberPosition,
    );
  }

  Map<String, dynamic> toMap() => {
    'themeMode': themeMode.index,
    'accentColor': accentColor.name,
    'blurIntensity': blurIntensity,
    'animationLevel': animationLevel,
    'crossfadeEnabled': crossfadeEnabled,
    'crossfadeDuration': crossfadeDuration,
    'gaplessPlayback': gaplessPlayback,
    'autoPlay': autoPlay,
    'rememberPosition': rememberPosition,
  };

  factory AppPreferences.fromMap(Map<String, dynamic> map) {
    final accentName = map['accentColor'] as String? ?? AccentColor.festival.name;
    final accent = accentColors.firstWhere(
      (a) => a.name == accentName,
      orElse: () => AccentColor.festival,
    );
    return AppPreferences(
      themeMode: AppThemeMode.values[map['themeMode'] as int? ?? 0],
      accentColor: accent,
      blurIntensity: (map['blurIntensity'] as num?)?.toDouble() ?? 1.0,
      animationLevel: (map['animationLevel'] as num?)?.toDouble() ?? 1.0,
      crossfadeEnabled: map['crossfadeEnabled'] as bool? ?? false,
      crossfadeDuration: (map['crossfadeDuration'] as num?)?.toDouble() ?? 3.0,
      gaplessPlayback: map['gaplessPlayback'] as bool? ?? true,
      autoPlay: map['autoPlay'] as bool? ?? false,
      rememberPosition: map['rememberPosition'] as bool? ?? true,
    );
  }
}

class PreferencesNotifier extends StateNotifier<AppPreferences> {
  Box<String>? _box;

  PreferencesNotifier() : super(const AppPreferences());

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    _box = await Hive.openBox<String>('preferences');
    final raw = _box!.get('app_prefs');
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        state = AppPreferences.fromMap(map);
      } catch (_) {}
    }
  }

  Future<void> _persist() async {
    await _box?.put('app_prefs', jsonEncode(state.toMap()));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist();
  }

  Future<void> setAccentColor(AccentColor color) async {
    state = state.copyWith(accentColor: color);
    await _persist();
  }

  Future<void> setBlurIntensity(double value) async {
    state = state.copyWith(blurIntensity: value.clamp(0.0, 1.0));
    await _persist();
  }

  Future<void> setAnimationLevel(double value) async {
    state = state.copyWith(animationLevel: value.clamp(0.0, 1.0));
    await _persist();
  }

  Future<void> setCrossfadeEnabled(bool value) async {
    state = state.copyWith(crossfadeEnabled: value);
    await _persist();
  }

  Future<void> setCrossfadeDuration(double value) async {
    state = state.copyWith(crossfadeDuration: value.clamp(1.0, 12.0));
    await _persist();
  }

  Future<void> setGaplessPlayback(bool value) async {
    state = state.copyWith(gaplessPlayback: value);
    await _persist();
  }

  Future<void> setAutoPlay(bool value) async {
    state = state.copyWith(autoPlay: value);
    await _persist();
  }

  Future<void> setRememberPosition(bool value) async {
    state = state.copyWith(rememberPosition: value);
    await _persist();
  }
}

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, AppPreferences>((ref) {
  return PreferencesNotifier();
});
