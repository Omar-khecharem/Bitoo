class PlaylistEntry {
  final int id;
  final String name;
  final String? description;
  final String? artworkUri;
  final List<String> songPaths;
  final int songCount;
  final int totalDurationMs;
  final bool isSmartPlaylist;
  final DateTime dateCreated;
  final DateTime dateModified;
  final String searchIndex;

  PlaylistEntry({
    this.id = 0,
    required this.name,
    this.description,
    this.artworkUri,
    this.songPaths = const [],
    this.songCount = 0,
    this.totalDurationMs = 0,
    this.isSmartPlaylist = false,
    required this.dateCreated,
    required this.dateModified,
    String? searchIndex,
  }) : searchIndex = searchIndex ?? name.toLowerCase();

  Duration get totalDuration => Duration(milliseconds: totalDurationMs);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'artworkUri': artworkUri,
    'songPaths': songPaths,
    'songCount': songCount,
    'totalDurationMs': totalDurationMs,
    'isSmartPlaylist': isSmartPlaylist,
    'dateCreated': dateCreated.toIso8601String(),
    'dateModified': dateModified.toIso8601String(),
    'searchIndex': searchIndex,
  };

  factory PlaylistEntry.fromMap(Map<String, dynamic> map) => PlaylistEntry(
    id: map['id'] as int? ?? 0,
    name: map['name'] as String? ?? '',
    description: map['description'] as String?,
    artworkUri: map['artworkUri'] as String?,
    songPaths: (map['songPaths'] as List<dynamic>?)?.cast<String>() ?? [],
    songCount: map['songCount'] as int? ?? 0,
    totalDurationMs: map['totalDurationMs'] as int? ?? 0,
    isSmartPlaylist: map['isSmartPlaylist'] as bool? ?? false,
    dateCreated: DateTime.parse(map['dateCreated'] as String),
    dateModified: DateTime.parse(map['dateModified'] as String),
    searchIndex: map['searchIndex'] as String?,
  );
}
