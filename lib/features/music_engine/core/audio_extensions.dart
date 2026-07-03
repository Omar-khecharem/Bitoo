import 'dart:io' show Platform;

class AudioExtensions {
  static const Set<String> supportedExtensions = {
    'mp3',
    'flac',
    'm4a',
    'wav',
    'ogg',
    'aac',
    'wma',
    'opus',
    'aiff',
    'alac',
    'dsf',
    'dff',
  };

  static const Set<String> losslessExtensions = {
    'flac',
    'wav',
    'aiff',
    'alac',
    'dsf',
    'dff',
  };

  static String titleFromPath(String path) {
    final separator = path.lastIndexOf(Platform.pathSeparator);
    var name = separator >= 0 ? path.substring(separator + 1) : path;
    final dot = name.lastIndexOf('.');
    if (dot >= 0) name = name.substring(0, dot);
    name = name.replaceAll(RegExp(r'^\d+\s*[-._]\s*'), '');
    name = name.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '');
    name = name.replaceAll(RegExp(r'\s*\[[^\]]*\]\s*$'), '');
    name = name.replaceAll(RegExp(r'[_]'), ' ');
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    return name;
  }

  static const Set<String> lossyExtensions = {
    'mp3',
    'm4a',
    'ogg',
    'aac',
    'wma',
    'opus',
  };

  static bool isLossless(String path) {
    final ext = path.split('.').last.toLowerCase();
    return losslessExtensions.contains(ext);
  }

  static bool isLossy(String path) {
    final ext = path.split('.').last.toLowerCase();
    return lossyExtensions.contains(ext);
  }
}
