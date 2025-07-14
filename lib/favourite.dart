import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunecrate/generated/app_localizations.dart';
import 'miniplayer.dart';
import 'playercontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  int _currentIndex = -1;

  void _playSong(PlayerController player, Map<String, dynamic> song, int index) {
    player.setPlaylist(favouriteSongs);
    player.setSong(song);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerController>(context);
final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFE2E2E2),
      body: SafeArea(
  child: Stack(
    children: [
      // main body
      favouriteSongs.isEmpty
          ? Column(
              children: [
                const SizedBox(height: 35),
                Text(
                  loc?.favorites ??"Favourites",
                  style: const TextStyle(
                    fontFamily: "Itim",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  height: 1,
                  color: Colors.grey,
                ),
                const SizedBox(height: 200),
                Text(loc?.nofavourite ??
                  "No Favourites",
                  style: const TextStyle(
                    fontFamily: "Itim",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    loc?.favsubtitle ??"Tap the heart icon on any song,\nplaylist, or album to add it to your favorites.\nYour saved music will appear\nhere for quick access!",
                    style: const TextStyle(
                      fontFamily: "Itim",
                      fontSize: 16,
                      color: Colors.black45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                const SizedBox(height: 16),
                Text(loc?.favorites ??
                  "Favourites",
                  style: const TextStyle(
                    fontFamily: "Itim",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 1,
                  color: Colors.black,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: favouriteSongs.length,
                    itemBuilder: (context, index) {
                      final song = favouriteSongs[index];
                      final isPlaying = player.currentSong != null &&
                          player.currentSong!['file'].path == song['file'].path;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: song['albumArt'] != null
                              ? Image.memory(
                                  song['albumArt'],
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
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
                              song['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Itim",
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            Text(
                              song['artist'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Itim",
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(height: 1, color: Colors.grey),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () async {
                            setState(() {
                              favouriteSongs.removeWhere((s) => s['file'].path == song['file'].path);
                            });
                            final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    'favorites',
    favouriteSongs
        .map((s) => s['file']?.path)
        .whereType<String>()
        .toList(),
  );

  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Removed from favourites")),
  );
                          },
                        ),
                        onTap: () => _playSong(player, song, index),
                      );
                    },
                  ),
                ),
              ],
            ),

      // miniplayer - always on top
      if (player.currentSong != null)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: buildMiniPlayer(
            context,
            player.player,
            player.currentSong,
            player.isPlaying,
            () {
              player.isPlaying ? player.pause() : player.play();
            },
            () {
              if (_currentIndex < favouriteSongs.length - 1) {
                _currentIndex++;
                final next = favouriteSongs[_currentIndex];
                player.setSong(next);
                setState(() {});
              }
            },
            () {
              if (_currentIndex > 0) {
                _currentIndex--;
                final prev = favouriteSongs[_currentIndex];
                player.setSong(prev);
                setState(() {});
              }
            },
          ),
        ),
    ],
  ),
)
    );
  }
}