import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class ArtworkCacheDataSource {
  final String _cacheDir;

  ArtworkCacheDataSource._(this._cacheDir);

  static Future<ArtworkCacheDataSource> create() async {
    final dir = await getApplicationCacheDirectory();
    final artworkDir = '${dir.path}${Platform.pathSeparator}artwork';
    await Directory(artworkDir).create(recursive: true);
    return ArtworkCacheDataSource._(artworkDir);
  }

  Future<String?> saveArtwork(String songSha256, Uint8List? imageBytes) async {
    if (imageBytes == null || imageBytes.isEmpty) return null;

    final path = '$_cacheDir${Platform.pathSeparator}$songSha256.jpg';
    final file = File(path);

    final resized = _resizeIfNeeded(imageBytes, 512);

    await file.writeAsBytes(resized);
    return path;
  }

  Future<File?> getArtwork(String songSha256) async {
    final path = '$_cacheDir${Platform.pathSeparator}$songSha256.jpg';
    final file = File(path);
    if (await file.exists()) return file;
    return null;
  }

  Future<int> getCacheSizeBytes() async {
    final dir = Directory(_cacheDir);
    if (!await dir.exists()) return 0;

    int total = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<int> clearCache() async {
    final dir = Directory(_cacheDir);
    if (!await dir.exists()) return 0;

    int deleted = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        await entity.delete();
        deleted++;
      }
    }
    return deleted;
  }

  Future<void> cleanOrphaned(Set<String> validSha256s) async {
    final dir = Directory(_cacheDir);
    if (!await dir.exists()) return;

    await for (final entity in dir.list()) {
      if (entity is File) {
        final name = _basenameWithoutExtension(entity.path);
        if (!validSha256s.contains(name)) {
          await entity.delete();
        }
      }
    }
  }

  String _basenameWithoutExtension(String path) {
    final separator = path.lastIndexOf(Platform.pathSeparator);
    final name = separator >= 0 ? path.substring(separator + 1) : path;
    final dot = name.lastIndexOf('.');
    return dot >= 0 ? name.substring(0, dot) : name;
  }

  Uint8List _resizeIfNeeded(Uint8List bytes, int maxDimension) {
    return bytes;
  }
}
