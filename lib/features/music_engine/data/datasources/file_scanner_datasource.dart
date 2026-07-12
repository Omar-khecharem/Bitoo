import 'dart:io';
import 'dart:async';
import '../../core/audio_extensions.dart' show AudioExtensions;
import '../../core/file_filters.dart';
import '../models/scan_progress.dart';
import 'package:rxdart/rxdart.dart';

class FileScannerDataSource {
  final _progressController = BehaviorSubject<ScanProgress>.seeded(
    const ScanProgress(filesScanned: 0, totalFiles: 0, currentPath: ''),
  );

  Stream<ScanProgress> get progressStream => _progressController.stream;

  Stream<File> scanAudioFiles(List<Directory> roots) async* {
    final allFiles = <File>[];
    for (final root in roots) {
      await for (final file in _walkDirectory(root)) {
        allFiles.add(file);
      }
    }

    _progressController.add(ScanProgress(
      filesScanned: 0,
      totalFiles: allFiles.length,
      currentPath: '',
    ));

    var scanned = 0;
    for (final file in allFiles) {
      scanned++;
      _progressController.add(ScanProgress(
        filesScanned: scanned,
        totalFiles: allFiles.length,
        currentPath: AudioExtensions.titleFromPath(file.path),
      ));
      yield file;
    }

    _progressController.add(const ScanProgress(
      filesScanned: 0,
      totalFiles: 0,
      currentPath: '',
      isComplete: true,
    ));
  }

  Stream<File> _walkDirectory(Directory dir) async* {
    try {
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && _isAudioFile(entity.path)) {
          yield entity;
        }
      }
    } on PathAccessException {
      // Ignore - directory access denied
    } on FileSystemException {
      // Ignore - filesystem error
    }
  }

  bool _isAudioFile(String path) {
    if (FileFilters.isHiddenOrSystemPath(path)) return false;
    final ext = path.split('.').last.toLowerCase();
    if (!AudioExtensions.supportedExtensions.contains(ext)) return false;
    try {
      return File(path).lengthSync() > 0;
    } catch (_) {
      return false;
    }
  }

  List<Directory> getDefaultScanRoots() {
    final roots = <Directory>[];
    if (Platform.isAndroid) {
      final candidates = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/audio',
        '/storage/emulated/0/Musique',
        '/storage/emulated/0/Músicas',
      ];
      for (final p in candidates) {
        final dir = Directory(p);
        try {
          if (dir.existsSync()) roots.add(dir);
        } catch (_) {}
      }

      // Try to find SD card or external storage
      try {
        final storageDir = Directory('/storage');
        if (storageDir.existsSync()) {
          for (final entity in storageDir.listSync()) {
            if (entity is Directory &&
                !FileFilters.isHiddenOrSystemPath(entity.path)) {
              final name = entity.path.split('/').last;
              if (name != 'emulated') {
                roots.add(entity);
              }
            }
          }
        }
      } catch (_) {}
    }
    return roots;
  }

  List<Directory> getFullScanRoots() {
    final roots = <Directory>[];
    if (Platform.isAndroid) {
      // With MANAGE_EXTERNAL_STORAGE, we can scan the entire internal storage
      roots.add(Directory('/storage/emulated/0'));

      // SD cards and external storage
      try {
        final storageDir = Directory('/storage');
        if (storageDir.existsSync()) {
          for (final entity in storageDir.listSync()) {
            if (entity is Directory &&
                !FileFilters.isHiddenOrSystemPath(entity.path)) {
              if (!roots.any((r) => r.path == entity.path)) {
                roots.add(entity);
              }
            }
          }
        }
      } catch (_) {}
    }
    return roots;
  }

  void dispose() {
    _progressController.close();
  }
}
