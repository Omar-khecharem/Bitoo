import 'dart:convert';
import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart' as meta;
import 'package:crypto/crypto.dart';
import '../../core/audio_extensions.dart' show AudioExtensions;

class AudioMetadata {
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
  final List<int>? artworkBytes;
  final String fileExtension;
  final int fileSize;
  final DateTime dateModified;

  AudioMetadata({
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
    required this.durationMs,
    required this.bitrate,
    required this.sampleRate,
    this.artworkBytes,
    required this.fileExtension,
    required this.fileSize,
    required this.dateModified,
  });
}

class MetadataDataSource {
  AudioMetadata? extract(String filePath) {
    try {
      final file = File(filePath);

      String title;
      String artist;
      String albumTitle;
      int durationMs = 0;
      int bitrate = 0;
      int sampleRate = 0;
      List<int>? artworkBytes;

      try {
        final metadata = meta.readMetadata(file, getImage: false);
        final rawTitle = metadata.title?.trim();
        title = (rawTitle != null && rawTitle.isNotEmpty)
            ? rawTitle
            : AudioExtensions.titleFromPath(filePath);
        artist = _cleanTag(metadata.artist) ?? 'Unknown Artist';
        albumTitle = _cleanTag(metadata.album) ?? 'Unknown Album';
        durationMs = metadata.duration?.inMilliseconds ?? 0;
        bitrate = metadata.bitrate ?? 0;
        sampleRate = metadata.sampleRate ?? 0;
        if (metadata.pictures.isNotEmpty) {
          artworkBytes = metadata.pictures.first.bytes.toList();
        }
      } catch (_) {
        return null;
      }

      FileStat? fileStat;
      try {
        fileStat = file.statSync();
      } catch (_) {}

      final fileSize = fileStat?.size ?? 0;
      final dateModified = fileStat?.modified ?? DateTime.now();
      final hash = sha256.convert(utf8.encode(filePath)).toString();
      final ext = _extension(filePath).toLowerCase();

      return AudioMetadata(
        filePath: filePath,
        sha256: hash,
        title: title,
        artist: artist,
        albumTitle: albumTitle,
        albumArtist: null,
        trackNumber: null,
        discNumber: null,
        year: null,
        genre: null,
        durationMs: durationMs,
        bitrate: bitrate,
        sampleRate: sampleRate,
        artworkBytes: artworkBytes,
        fileExtension: ext,
        fileSize: fileSize,
        dateModified: dateModified,
      );
    } catch (e) {
      return null;
    }
  }

  String? _cleanTag(String? tag) {
    if (tag == null) return null;
    final cleaned = tag.trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  String _extension(String path) {
    final dot = path.lastIndexOf('.');
    return dot >= 0 ? path.substring(dot) : '';
  }
}
