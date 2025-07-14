import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunecrate/playercontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';

class NowPlayingDetailPage extends StatelessWidget {
  const NowPlayingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(builder: (context, player, _) {
      final song = player.currentSong;
      final isPlaying = player.isPlaying;

      if (song == null) {
        return const Center(child: Text("No song playing"));
      }

      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFA5D1F5),
                Color(0xFFA9A9A9),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (song['albumArt'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(song['albumArt'], height: 120),
                      )
                    else
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.music_note, size: 100),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      '${song['title']} - ${song['artist']}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: "Itim",
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: Icon(
                        favouriteSongs.any((s) => s['file'].path == song['file'].path)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () async {
  final prefs = await SharedPreferences.getInstance();
  final isFav = favouriteSongs.any((s) => s['file'].path == song['file'].path);
  if (isFav) {
    favouriteSongs.removeWhere((s) => s['file'].path == song['file'].path);
  } else {
    favouriteSongs.add(song);
  }
  await prefs.setStringList(
    'favorites',
    favouriteSongs.map((s) => s['file']?.path).whereType<String>().toList(),
  );
  // force a rebuild:
  (context as Element).markNeedsBuild();
},
                    ),
                    const SizedBox(height: 5),
                    StreamBuilder<Duration>(
                      stream: player.player.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = player.player.duration ?? Duration.zero;
                        return Column(
                          children: [
                            Slider(
                              value: position.inSeconds.toDouble(),
                              max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1,
                              onChanged: (value) {
                                player.player.seek(Duration(seconds: value.toInt()));
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatDuration(position)),
                                Text(formatDuration(duration)),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 36),
                          onPressed: player.previousSong,
                        ),
                        IconButton(
                          icon: Icon(
                              isPlaying ? Icons.pause_circle : Icons.play_circle,
                              size: 36),
                          onPressed: () {
                            if (isPlaying) {
                              player.pause();
                            } else {
                              player.play();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 36),
                          onPressed: player.nextSong,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
