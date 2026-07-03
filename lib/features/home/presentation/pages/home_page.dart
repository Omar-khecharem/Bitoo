import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/theme/tokens.dart';
import '../providers/home_provider.dart';
import '../../../music_engine/core/audio_extensions.dart';
import '../../../music_engine/data/database/song.dart';
import '../../../music_engine/presentation/providers/music_engine_provider.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/pages/fullscreen_player_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final allSongsAsync = ref.watch(allSongsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('My Music', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: allSongsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary500),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('$e', style: TextStyle(color: Colors.red, fontSize: 14), textAlign: TextAlign.center),
          ),
        ),
        data: (songs) {
          if (songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary500, strokeWidth: 2),
                  SizedBox(height: 16),
                  Text('Scanning your music...', style: TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.only(top: 8, bottom: 100),
            itemCount: songs.length,
            itemBuilder: (_, i) => _SongTile(song: songs[i]),
          );
        },
      ),
    );
  }
}

class _SongTile extends ConsumerWidget {
  final Song song;

  const _SongTile({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.music_note_rounded, color: Colors.white.withValues(alpha: 0.25), size: 22),
        ),
        title: Text(
          AudioExtensions.titleFromPath(song.filePath),
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist.isNotEmpty && song.artist != 'Unknown Artist'
              ? song.artist
              : '',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatDuration(song.durationMs),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
        ),
        onTap: () {
          final handler = ref.read(audioHandlerProvider);
          final title = AudioExtensions.titleFromPath(song.filePath);
          final artist = song.artist.isNotEmpty && song.artist != 'Unknown Artist'
              ? song.artist
              : '';
          handler.setFilePath(
            song.filePath,
            title: title,
            artist: artist,
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FullscreenPlayerPage(
                filePath: song.filePath,
                title: title,
                artist: artist,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(int ms) {
    if (ms <= 0) return '--:--';
    final sec = ms ~/ 1000;
    final min = sec ~/ 60;
    return '${min.toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';
  }
}
