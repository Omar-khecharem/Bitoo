class Genre {
  final int id;
  final String name;
  final int songCount;
  final int albumCount;
  final DateTime dateAdded;

  const Genre({
    this.id = 0,
    required this.name,
    this.songCount = 0,
    this.albumCount = 0,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'songCount': songCount,
        'albumCount': albumCount,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory Genre.fromMap(Map<String, dynamic> map) => Genre(
        id: map['id'] as int? ?? 0,
        name: map['name'] as String? ?? '',
        songCount: map['songCount'] as int? ?? 0,
        albumCount: map['albumCount'] as int? ?? 0,
        dateAdded: DateTime.parse(map['dateAdded'] as String),
      );
}
