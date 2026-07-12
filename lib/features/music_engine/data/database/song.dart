class Song {
  final int id;
  final String filePath;
  final String sha256;
  final String title;
  final String artist;
  final String albumTitle;
  final String? albumArtist;
  final int? trackNumber;
  final int? discNumber;
  final int? year;
  final String? genre;
  final int durationMs;
  final int bitrate;
  final int sampleRate;
  final String? artworkPath;
  final bool? hasArtwork;
  final String fileExtension;
  final int fileSize;
  final DateTime dateAdded;
  final DateTime dateModified;
  final DateTime? lastPlayed;
  final int playCount;
  final bool isFavorite;
  final bool isCorrupted;
  final String searchIndex;

  Song({
    this.id = 0,
    required this.filePath,
    required this.sha256,
    required this.title,
    required this.artist,
    required this.albumTitle,
    this.albumArtist,
    this.trackNumber,
    this.discNumber,
    this.year,
    this.genre,
    this.durationMs = 0,
    this.bitrate = 0,
    this.sampleRate = 0,
    this.artworkPath,
    this.hasArtwork,
    this.fileExtension = '',
    this.fileSize = 0,
    required this.dateAdded,
    required this.dateModified,
    this.lastPlayed,
    this.playCount = 0,
    this.isFavorite = false,
    this.isCorrupted = false,
    String? searchIndex,
  }) : searchIndex = searchIndex ?? '$title $artist $albumTitle'.toLowerCase();

  Duration get duration => Duration(milliseconds: durationMs);

  Map<String, dynamic> toMap() => {
        'id': id,
        'filePath': filePath,
        'sha256': sha256,
        'title': title,
        'artist': artist,
        'albumTitle': albumTitle,
        'albumArtist': albumArtist,
        'trackNumber': trackNumber,
        'discNumber': discNumber,
        'year': year,
        'genre': genre,
        'durationMs': durationMs,
        'bitrate': bitrate,
        'sampleRate': sampleRate,
        'artworkPath': artworkPath,
        'hasArtwork': hasArtwork,
        'fileExtension': fileExtension,
        'fileSize': fileSize,
        'dateAdded': dateAdded.toIso8601String(),
        'dateModified': dateModified.toIso8601String(),
        'lastPlayed': lastPlayed?.toIso8601String(),
        'playCount': playCount,
        'isFavorite': isFavorite,
        'isCorrupted': isCorrupted,
        'searchIndex': searchIndex,
      };

  factory Song.fromMap(Map<String, dynamic> map) => Song(
        id: map['id'] as int? ?? 0,
        filePath: map['filePath'] as String? ?? '',
        sha256: map['sha256'] as String? ?? '',
        title: map['title'] as String? ?? '',
        artist: map['artist'] as String? ?? '',
        albumTitle: map['albumTitle'] as String? ?? '',
        albumArtist: map['albumArtist'] as String?,
        trackNumber: map['trackNumber'] as int?,
        discNumber: map['discNumber'] as int?,
        year: map['year'] as int?,
        genre: map['genre'] as String?,
        durationMs: map['durationMs'] as int? ?? 0,
        bitrate: map['bitrate'] as int? ?? 0,
        sampleRate: map['sampleRate'] as int? ?? 0,
        artworkPath: map['artworkPath'] as String?,
        hasArtwork: map['hasArtwork'] as bool?,
        fileExtension: map['fileExtension'] as String? ?? '',
        fileSize: map['fileSize'] as int? ?? 0,
        dateAdded: DateTime.parse(map['dateAdded'] as String),
        dateModified: DateTime.parse(map['dateModified'] as String),
        lastPlayed: map['lastPlayed'] != null
            ? DateTime.parse(map['lastPlayed'] as String)
            : null,
        playCount: map['playCount'] as int? ?? 0,
        isFavorite: map['isFavorite'] as bool? ?? false,
        isCorrupted: map['isCorrupted'] as bool? ?? false,
        searchIndex: map['searchIndex'] as String?,
      );

  Song copyWith({
    int? id,
    String? filePath,
    String? sha256,
    String? title,
    String? artist,
    String? albumTitle,
    String? albumArtist,
    int? trackNumber,
    int? discNumber,
    int? year,
    String? genre,
    int? durationMs,
    int? bitrate,
    int? sampleRate,
    String? artworkPath,
    bool? hasArtwork,
    String? fileExtension,
    int? fileSize,
    DateTime? dateAdded,
    DateTime? dateModified,
    DateTime? lastPlayed,
    int? playCount,
    bool? isFavorite,
    bool? isCorrupted,
    String? searchIndex,
  }) {
    return Song(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      sha256: sha256 ?? this.sha256,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumTitle: albumTitle ?? this.albumTitle,
      albumArtist: albumArtist ?? this.albumArtist,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      durationMs: durationMs ?? this.durationMs,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      artworkPath: artworkPath ?? this.artworkPath,
      hasArtwork: hasArtwork ?? this.hasArtwork,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSize: fileSize ?? this.fileSize,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isCorrupted: isCorrupted ?? this.isCorrupted,
      searchIndex: searchIndex ?? this.searchIndex,
    );
  }
}
