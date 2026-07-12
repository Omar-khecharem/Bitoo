import 'dart:io' show Platform;

class FileFilters {
  static const _hiddenPrefixes = [
    '.',
    '__',
    'node_modules',
    'System Volume Information',
    '\$RECYCLE.BIN'
  ];

  static const _systemPaths = [
    '/system',
    '/proc',
    '/dev',
    '/sys',
    '/acct',
    '/config',
    '/etc',
    '/vendor',
    '/data/dalvik-cache',
    '/data/app',
    '/data/system',
  ];

  static bool isHiddenOrSystemPath(String path) {
    final segments = path.split(Platform.pathSeparator);
    for (final segment in segments) {
      if (_hiddenPrefixes.any((p) => segment.startsWith(p))) return true;
    }
    for (final sys in _systemPaths) {
      if (path.startsWith(sys)) return true;
    }
    return false;
  }

  static bool isRecycleBin(String path) {
    return path.contains('\$RECYCLE.BIN') ||
        path.contains('.Trash') ||
        path.contains('.trash') ||
        path.contains('LOST.DIR');
  }
}
