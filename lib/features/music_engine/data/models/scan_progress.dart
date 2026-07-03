class ScanProgress {
  final int filesScanned;
  final int totalFiles;
  final String currentPath;
  final bool isComplete;
  final int? newSongs;
  final int? corruptedFiles;
  final String? diagnostic;

  const ScanProgress({
    required this.filesScanned,
    required this.totalFiles,
    required this.currentPath,
    this.isComplete = false,
    this.newSongs,
    this.corruptedFiles,
    this.diagnostic,
  });

  double get percentage =>
      totalFiles > 0 ? filesScanned / totalFiles : 0.0;
}
