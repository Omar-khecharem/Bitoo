import '../../domain/entities/preset_config.dart';

class PresetModel {
  final String name;
  final String label;
  final List<int> bandMillibels;
  final int bassBoostStrength;
  final int virtualizerStrength;
  final int? loudnessTargetGain;

  const PresetModel({
    required this.name,
    required this.label,
    required this.bandMillibels,
    required this.bassBoostStrength,
    required this.virtualizerStrength,
    this.loudnessTargetGain,
  });

  factory PresetModel.fromPresetConfig(PresetConfig config) => PresetModel(
    name: config.name,
    label: config.label,
    bandMillibels: config.bands.map((b) => (b * 100).round()).toList(),
    bassBoostStrength: (config.bassBoost * 1000).round(),
    virtualizerStrength: (config.virtualizerStrength * 1000).round(),
    loudnessTargetGain: config.loudnessTargetGain,
  );

  PresetConfig toPresetConfig() => PresetConfig(
    name: name,
    label: label,
    bands: bandMillibels.map((b) => b / 100.0).toList(),
    bassBoost: bassBoostStrength / 1000.0,
    virtualizerStrength: virtualizerStrength / 1000.0,
    loudnessTargetGain: loudnessTargetGain,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'label': label,
    'bandMillibels': bandMillibels,
    'bassBoostStrength': bassBoostStrength,
    'virtualizerStrength': virtualizerStrength,
    'loudnessTargetGain': loudnessTargetGain,
  };

  factory PresetModel.fromJson(Map<String, dynamic> json) => PresetModel(
    name: json['name'] as String,
    label: json['label'] as String,
    bandMillibels: (json['bandMillibels'] as List).cast<int>(),
    bassBoostStrength: json['bassBoostStrength'] as int,
    virtualizerStrength: json['virtualizerStrength'] as int,
    loudnessTargetGain: json['loudnessTargetGain'] as int?,
  );
}
