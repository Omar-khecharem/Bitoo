class Album {
  final int id;
  final String title;
  final String artist;
  final int? year;
  final String? genre;
  final int songCount;
  final int totalDurationMs;
  final String? artworkPath;
  final DateTime dateAdded;
  final String searchIndex;

  Album({
    this.id = 0,
    required this.title,
    required this.artist,
    this.year,
    this.genre,
    this.songCount = 0,
    this.totalDurationMs = 0,
    this.artworkPath,
    required this.dateAdded,
    String? searchIndex,
  }) : searchIndex = searchIndex ?? '$title $artist'.toLowerCase();

  Duration get totalDuration => Duration(milliseconds: totalDurationMs);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'year': year,
        'genre': genre,
        'songCount': songCount,
        'totalDurationMs': totalDurationMs,
        'artworkPath': artworkPath,
        'dateAdded': dateAdded.toIso8601String(),
        'searchIndex': searchIndex,
      };

  factory Album.fromMap(Map<String, dynamic> map) => Album(
        id: map['id'] as int? ?? 0,
        title: map['title'] as String? ?? '',
        artist: map['artist'] as String? ?? '',
        year: map['year'] as int?,
        genre: map['genre'] as String?,
        songCount: map['songCount'] as int? ?? 0,
        totalDurationMs: map['totalDurationMs'] as int? ?? 0,
        artworkPath: map['artworkPath'] as String?,
        dateAdded: DateTime.parse(map['dateAdded'] as String),
        searchIndex: map['searchIndex'] as String?,
      );
}
