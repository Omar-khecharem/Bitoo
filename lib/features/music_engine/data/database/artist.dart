class Artist {
  final int id;
  final String name;
  final int albumCount;
  final int songCount;
  final int totalDurationMs;
  final String? artworkPath;
  final DateTime dateAdded;
  final String searchIndex;

  Artist({
    this.id = 0,
    required this.name,
    this.albumCount = 0,
    this.songCount = 0,
    this.totalDurationMs = 0,
    this.artworkPath,
    required this.dateAdded,
    String? searchIndex,
  }) : searchIndex = searchIndex ?? name.toLowerCase();

  Duration get totalDuration => Duration(milliseconds: totalDurationMs);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'albumCount': albumCount,
        'songCount': songCount,
        'totalDurationMs': totalDurationMs,
        'artworkPath': artworkPath,
        'dateAdded': dateAdded.toIso8601String(),
        'searchIndex': searchIndex,
      };

  factory Artist.fromMap(Map<String, dynamic> map) => Artist(
        id: map['id'] as int? ?? 0,
        name: map['name'] as String? ?? '',
        albumCount: map['albumCount'] as int? ?? 0,
        songCount: map['songCount'] as int? ?? 0,
        totalDurationMs: map['totalDurationMs'] as int? ?? 0,
        artworkPath: map['artworkPath'] as String?,
        dateAdded: DateTime.parse(map['dateAdded'] as String),
        searchIndex: map['searchIndex'] as String?,
      );
}
