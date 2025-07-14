import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunecrate/globals.dart';
import 'package:tunecrate/miniplayer.dart';
import 'playercontroller.dart';

class PlaylistDetailPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> songs;

  const PlaylistDetailPage({
    super.key,
    required this.title,
    required this.songs,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  bool deleteMode = false;
  @override
  Widget build(BuildContext context) {
      final player = Provider.of<PlayerController>(context);

    final isCustomPlaylist = userPlaylists.any((p) => p['name'] == widget.title);

    return Scaffold(
      backgroundColor: const Color(0xFFE2E2E2),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: "Itim",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
                if (isCustomPlaylist)
                  IconButton(
                    icon: Icon(
                      deleteMode ? Icons.delete_forever : Icons.delete,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        deleteMode = !deleteMode;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              height: 1,
              color: Colors.grey,
            ),
            Expanded(
              child: Consumer<PlayerController>(
    builder: (context, player, _) {
      return ListView.builder(
                itemCount: widget.songs.length,
                itemBuilder: (context, index) {
                  final song = widget.songs[index];
                  final isCurrent = player.currentSong?['file'].path == song['file'].path;
return ListTile(
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  leading: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: song['albumArt'] != null
        ? Image.memory(song['albumArt'], width: 48, height: 48, fit: BoxFit.cover)
        : Container(
            width: 48,
            height: 48,
            color: Colors.grey,
            child: const Icon(Icons.music_note, color: Colors.black),
          ),
  ),
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        song['title'] ?? 'Unknown',
        style: TextStyle(
          fontFamily: "Itim",
          fontSize: 14,
          color: Colors.black,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        song['artist'] ?? '',
        style: const TextStyle(
          fontFamily: "Itim",
          fontSize: 12,
          color: Colors.black54,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4),
      Container(height: 1, color: Colors.grey),
    ],
  ),
   trailing: isCustomPlaylist && deleteMode
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () async {
                              setState(() {
                                widget.songs.removeAt(index);
                              });

                              // Update userPlaylists and SharedPreferences
                              final idx = userPlaylists.indexWhere((p) => p['name'] == widget.title);
                              if (idx != -1) {
                                userPlaylists[idx]['songs'] = widget.songs;
                                await saveUserPlaylists();
                              }
                            },
                          )
                        : null,
  onTap: () {
    if (!deleteMode) {
    player.setSong(song);
  }
  },
);

                },
              );
    },
            ),),
            if (player.currentSong != null)
              buildMiniPlayer(
                context,
                player.player,
                player.currentSong!,
                player.isPlaying,
                () {
                  player.isPlaying ? player.pause() : player.play();
                },
                () => player.nextSong(),
                () => player.previousSong(),
              ),
          ],
        ),
      ),
    );
  }
}
