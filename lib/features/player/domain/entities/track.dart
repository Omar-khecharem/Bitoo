class TrackEntity {
  final String id;
  final String title;
  final String artist;
  final String albumTitle;
  final String albumArtUrl;
  final Duration duration;
  final String audioUrl;
  final bool isFavorite;
  final int trackNumber;
  final String? albumId;
  final String? artistId;
  final String? lyricsUrl;
  final double bpm;
  final List<String> genres;

  const TrackEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumTitle,
    required this.albumArtUrl,
    required this.duration,
    required this.audioUrl,
    this.isFavorite = false,
    this.trackNumber = 0,
    this.albumId,
    this.artistId,
    this.lyricsUrl,
    this.bpm = 0.0,
    this.genres = const [],
  });

  factory TrackEntity.fromJson(Map<String, dynamic> json) => TrackEntity(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        artist: json['artist'] as String? ?? '',
        albumTitle: json['albumTitle'] as String? ?? '',
        albumArtUrl: json['albumArtUrl'] as String? ?? '',
        duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
        audioUrl: json['audioUrl'] as String? ?? '',
        isFavorite: json['isFavorite'] as bool? ?? false,
        trackNumber: json['trackNumber'] as int? ?? 0,
        albumId: json['albumId'] as String?,
        artistId: json['artistId'] as String?,
        lyricsUrl: json['lyricsUrl'] as String?,
        bpm: (json['bpm'] as num?)?.toDouble() ?? 0.0,
        genres: (json['genres'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'albumTitle': albumTitle,
        'albumArtUrl': albumArtUrl,
        'durationMs': duration.inMilliseconds,
        'audioUrl': audioUrl,
        'isFavorite': isFavorite,
        'trackNumber': trackNumber,
        'albumId': albumId,
        'artistId': artistId,
        'lyricsUrl': lyricsUrl,
        'bpm': bpm,
        'genres': genres,
      };

  TrackEntity copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumTitle,
    String? albumArtUrl,
    Duration? duration,
    String? audioUrl,
    bool? isFavorite,
    int? trackNumber,
    String? albumId,
    String? artistId,
    String? lyricsUrl,
    double? bpm,
    List<String>? genres,
  }) {
    return TrackEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumTitle: albumTitle ?? this.albumTitle,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      trackNumber: trackNumber ?? this.trackNumber,
      albumId: albumId ?? this.albumId,
      artistId: artistId ?? this.artistId,
      lyricsUrl: lyricsUrl ?? this.lyricsUrl,
      bpm: bpm ?? this.bpm,
      genres: genres ?? this.genres,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackEntity &&
          id == other.id &&
          title == other.title &&
          artist == other.artist &&
          albumTitle == other.albumTitle;

  @override
  int get hashCode => Object.hash(id, title, artist, albumTitle);
}
