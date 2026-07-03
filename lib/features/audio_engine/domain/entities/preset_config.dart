class PresetConfig {
  final String name;
  final String label;
  final List<double> bands;
  final double bassBoost;
  final double virtualizerStrength;
  final int? loudnessTargetGain;

  const PresetConfig({
    required this.name,
    required this.label,
    required this.bands,
    required this.bassBoost,
    required this.virtualizerStrength,
    this.loudnessTargetGain,
  });

  static const List<double> flat = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  static const List<double> rock = [4.0, 3.5, 2.0, -1.0, -1.5, 0.0, 1.0, 2.0, 2.5, 2.0];
  static const List<double> pop = [3.0, 4.0, 2.5, 1.5, 0.0, 0.5, 1.5, 2.0, 1.0, 0.5];
  static const List<double> jazz = [2.0, 2.5, 2.0, 1.0, 1.5, 1.0, 0.5, 0.0, -0.5, -1.0];
  static const List<double> classic = [1.0, 1.5, 0.5, 0.0, 0.5, 1.0, 2.0, 2.5, 2.0, 1.0];
  static const List<double> electronic = [5.0, 5.5, 4.0, 2.0, 0.0, 0.5, 1.5, 2.5, 3.0, 3.5];
  static const List<double> podcast = [0.0, 0.0, -1.0, -2.0, -2.5, -1.0, 1.0, 2.5, 4.0, 3.5];
  static const List<double> movie = [3.0, 4.0, 3.0, 2.0, -1.0, -2.0, -1.0, 0.0, 1.0, 1.5];
  static const List<double> gaming = [4.0, 5.0, 3.5, 1.0, 0.0, -0.5, 1.0, 2.0, 2.5, 3.0];
  static const List<double> voice = [-1.0, -1.0, -1.5, -2.0, -1.0, 2.0, 3.0, 3.5, 2.0, 1.5];

  static const Map<String, PresetConfig> presets = {
    'flat': PresetConfig(name: 'flat', label: 'Flat', bands: flat, bassBoost: 0.0, virtualizerStrength: 0.0),
    'rock': PresetConfig(name: 'rock', label: 'Rock', bands: rock, bassBoost: 0.6, virtualizerStrength: 0.4),
    'pop': PresetConfig(name: 'pop', label: 'Pop', bands: pop, bassBoost: 0.4, virtualizerStrength: 0.5),
    'jazz': PresetConfig(name: 'jazz', label: 'Jazz', bands: jazz, bassBoost: 0.3, virtualizerStrength: 0.7),
    'classic': PresetConfig(name: 'classic', label: 'Classic', bands: classic, bassBoost: 0.2, virtualizerStrength: 0.6),
    'electronic': PresetConfig(name: 'electronic', label: 'Electronic', bands: electronic, bassBoost: 0.8, virtualizerStrength: 0.65),
    'podcast': PresetConfig(name: 'podcast', label: 'Podcast', bands: podcast, bassBoost: 0.0, virtualizerStrength: 0.2),
    'movie': PresetConfig(name: 'movie', label: 'Movie', bands: movie, bassBoost: 0.7, virtualizerStrength: 0.8),
    'gaming': PresetConfig(name: 'gaming', label: 'Gaming', bands: gaming, bassBoost: 0.65, virtualizerStrength: 0.75),
    'voice': PresetConfig(name: 'voice', label: 'Voice', bands: voice, bassBoost: 0.0, virtualizerStrength: 0.3),
  };

  static const List<String> presetNames = [
    'flat', 'rock', 'pop', 'jazz', 'classic', 'electronic', 'podcast', 'movie', 'gaming', 'voice',
  ];

  Map<String, dynamic> toJson() => {
    'name': name,
    'label': label,
    'bands': bands,
    'bassBoost': bassBoost,
    'virtualizerStrength': virtualizerStrength,
    'loudnessTargetGain': loudnessTargetGain,
  };

  factory PresetConfig.fromJson(Map<String, dynamic> json) => PresetConfig(
    name: json['name'] as String,
    label: json['label'] as String,
    bands: (json['bands'] as List).cast<double>(),
    bassBoost: (json['bassBoost'] as num).toDouble(),
    virtualizerStrength: (json['virtualizerStrength'] as num).toDouble(),
    loudnessTargetGain: json['loudnessTargetGain'] as int?,
  );

  PresetConfig copyWith({
    String? name,
    String? label,
    List<double>? bands,
    double? bassBoost,
    double? virtualizerStrength,
    int? loudnessTargetGain,
  }) => PresetConfig(
    name: name ?? this.name,
    label: label ?? this.label,
    bands: bands ?? this.bands,
    bassBoost: bassBoost ?? this.bassBoost,
    virtualizerStrength: virtualizerStrength ?? this.virtualizerStrength,
    loudnessTargetGain: loudnessTargetGain ?? this.loudnessTargetGain,
  );
}
