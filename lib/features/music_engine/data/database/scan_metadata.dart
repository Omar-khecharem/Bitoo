class ScanMetadata {
  final int id;
  final DateTime lastScanTimestamp;
  final int totalSongs;
  final int totalAlbums;
  final int totalArtists;
  final int totalGenres;
  final double scanDurationSeconds;
  final int corruptedFiles;
  final int skippedFiles;
  final String? lastScanError;

  const ScanMetadata({
    this.id = 0,
    required this.lastScanTimestamp,
    this.totalSongs = 0,
    this.totalAlbums = 0,
    this.totalArtists = 0,
    this.totalGenres = 0,
    this.scanDurationSeconds = 0.0,
    this.corruptedFiles = 0,
    this.skippedFiles = 0,
    this.lastScanError,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'lastScanTimestamp': lastScanTimestamp.toIso8601String(),
    'totalSongs': totalSongs,
    'totalAlbums': totalAlbums,
    'totalArtists': totalArtists,
    'totalGenres': totalGenres,
    'scanDurationSeconds': scanDurationSeconds,
    'corruptedFiles': corruptedFiles,
    'skippedFiles': skippedFiles,
    'lastScanError': lastScanError,
  };

  factory ScanMetadata.fromMap(Map<String, dynamic> map) => ScanMetadata(
    id: map['id'] as int? ?? 0,
    lastScanTimestamp: DateTime.parse(map['lastScanTimestamp'] as String),
    totalSongs: map['totalSongs'] as int? ?? 0,
    totalAlbums: map['totalAlbums'] as int? ?? 0,
    totalArtists: map['totalArtists'] as int? ?? 0,
    totalGenres: map['totalGenres'] as int? ?? 0,
    scanDurationSeconds: (map['scanDurationSeconds'] as num?)?.toDouble() ?? 0.0,
    corruptedFiles: map['corruptedFiles'] as int? ?? 0,
    skippedFiles: map['skippedFiles'] as int? ?? 0,
    lastScanError: map['lastScanError'] as String?,
  );
}
