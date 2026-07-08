import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../music_engine/core/audio_extensions.dart';
import '../music_engine/presentation/providers/music_engine_provider.dart';
import '../player/presentation/providers/player_provider.dart';

class DiagnosticResult {
  final String filePath;
  final String title;
  final bool fileExists;
  final int? fileSize;
  final String? error;

  DiagnosticResult({
    required this.filePath,
    required this.title,
    required this.fileExists,
    this.fileSize,
    this.error,
  });
}

class MusicDiagnosticsPage extends ConsumerStatefulWidget {
  const MusicDiagnosticsPage({super.key});

  @override
  ConsumerState<MusicDiagnosticsPage> createState() => _MusicDiagnosticsPageState();
}

class _MusicDiagnosticsPageState extends ConsumerState<MusicDiagnosticsPage> {
  final List<DiagnosticResult> _results = [];
  bool _running = false;
  DiagnosticResult? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runDiagnostics());
  }

  Future<void> _runDiagnostics() async {
    setState(() => _running = true);
    _results.clear();

    final repo = await ref.read(musicRepositoryProvider.future);
    final songs = await repo.getAllSongs();

    for (final song in songs) {
      final file = File(song.filePath);
      bool exists = false;
      int? size;
      String? error;

      try {
        exists = await file.exists();
        if (exists) {
          final stat = await file.stat();
          size = stat.size;
        }
      } catch (e) {
        error = 'Erreur stat: $e';
      }

      if (exists && size == 0) {
        error = 'Fichier vide (0 octets)';
      }

      _results.add(DiagnosticResult(
        filePath: song.filePath,
        title: song.title.isNotEmpty ? song.title : AudioExtensions.titleFromPath(song.filePath),
        fileExists: exists,
        fileSize: size,
        error: error,
      ));

      if (mounted) setState(() {});
    }

    setState(() => _running = false);
  }

  int get _okCount => _results.where((r) => r.fileExists && r.error == null).length;
  int get _missingCount => _results.where((r) => !r.fileExists).length;
  int get _errorCount => _results.where((r) => r.fileExists && r.error != null).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Diagnostic Audio', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          if (!_running)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _runDiagnostics,
            ),
        ],
      ),
      body: _running
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF7C5CFF)),
                  const SizedBox(height: 16),
                  Text('${_results.length} fichiers analysés...',
                      style: const TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            )
          : _results.isEmpty
              ? const Center(child: Text('Aucune chanson trouvée', style: TextStyle(color: Colors.white54)))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF2A2A2A),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                      _statBadge('OK', _okCount, const Color(0xFF00E0FF)),
                      _statBadge('Manquant', _missingCount, const Color(0xFFFF4D6D)),
                      _statBadge('Erreur', _errorCount, Colors.orangeAccent),
                      _statBadge('Total', _results.length, Colors.white54),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _selected != null ? _buildDetail() : _buildList(),
                    ),
                  ],
                ),
    );
  }

  Widget _statBadge(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$count', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildList() {
    final sorted = List<DiagnosticResult>.from(_results)
      ..sort((a, b) {
        final aFail = !a.fileExists || a.error != null ? 0 : 1;
        final bFail = !b.fileExists || b.error != null ? 0 : 1;
        return aFail.compareTo(bFail);
      });

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final r = sorted[index];
        final ok = r.fileExists && r.error == null;
        return ListTile(
          dense: true,
          leading: Icon(
            ok ? Icons.check_circle : Icons.error,
            color: ok ? const Color(0xFF00E0FF) : const Color(0xFFFF4D6D),
            size: 18,
          ),
          title: Text(
            r.title,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            r.filePath,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: ok
              ? Text(formatFileSize(r.fileSize ?? 0),
                  style: const TextStyle(color: Colors.white38, fontSize: 10))
              : Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.3), size: 12),
          onTap: ok ? null : () => setState(() => _selected = r),
        );
      },
    );
  }

  Widget _buildDetail() {
    final r = _selected!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => setState(() => _selected = null),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(r.title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow('Chemin', r.filePath),
          _DetailRow('Existe', r.fileExists ? 'Oui' : 'Non'),
          if (r.fileSize != null) _DetailRow('Taille', formatFileSize(r.fileSize!)),
          if (r.error != null) _DetailRow('Erreur', r.error!, isError: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final handler = ref.read(audioHandlerProvider);
                final file = File(r.filePath);
                if (await file.exists()) {
                  handler.setFilePath(r.filePath, title: r.title);
                }
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Tester la lecture'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isError;

  const _DetailRow(this.label, this.value, {this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  color: isError ? const Color(0xFFFF4D6D) : Colors.white,
                  fontSize: 12,
                )),
          ),
        ],
      ),
    );
  }
}
