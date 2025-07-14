import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunecrate/generated/app_localizations.dart';
import 'package:tunecrate/miniplayer.dart';
import 'globals.dart';
import 'playlist_detail.dart';
import 'playercontroller.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final TextEditingController _playlistNameController = TextEditingController();
  bool showCreateBox = false;

  List get playlists => userPlaylists;

  void _createPlaylist() async {
    final name = _playlistNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      playlists.add({'name': name, 'songs': []});
      _playlistNameController.clear();
      showCreateBox = false;
    });
    await saveUserPlaylists();
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE2E2E2),
      body: SafeArea(
        child: Consumer<PlayerController>(
          builder: (context, player, _) {
            final recentPlayed = player.recentPlayed;
            final mostPlayed = player.mostPlayed;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            loc?.playlist ?? "Playlists",
                            style: const TextStyle(
                              fontFamily: "Itim",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          height: 1,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 25),

                        // horizontal scroll
                        SizedBox(
                          height: 200,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              _buildPlaylistTile(
                                context,
                                loc?.recentplayer ?? "Recently Played",
                                recentPlayed,
                              ),
                              _buildPlaylistTile(
                                context,
                                loc?.mostplayed ?? "Most Played",
                                mostPlayed,
                              ),
                              ...playlists.map((playlist) {
                                return _buildPlaylistTile(
                                  context,
                                  playlist['name'],
                                  List<Map<String, dynamic>>.from(
                                      playlist['songs']),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showCreateBox = true;
                            });
                          },
                          child: Column(
                            children: [
                              const Icon(Icons.add,
                                  size: 80, color: Colors.grey),
                              const SizedBox(height: 15),
                              Text(
                                loc?.createplaylist ?? "Create Your Playlist",
                                style: const TextStyle(
                                  fontFamily: "Itim",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (showCreateBox)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _playlistNameController,
                                    decoration: InputDecoration(
                                      hintText:
                                          loc?.enterplaylistname ??
                                              "Enter playlist name",
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: _createPlaylist,
                                    child: Text(loc?.create ?? "Create"),
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
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
            );
          },
        ),
      ),
    );
  }

Widget _buildPlaylistTile(BuildContext context, String title, List<Map<String, dynamic>> songs) {
  final isCustomPlaylist = userPlaylists.any((p) => p['name'] == title);

  return Column(
    children: [
      Stack(
        children: [
          GestureDetector(
            onTap: () async  {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistDetailPage(title: title, songs: songs),
                ),
              );
              setState(() {});
            },
            child: Container(
              width: 125,
              height: 133,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                // ignore: use_full_hex_values_for_flutter_colors
                color: const Color(0xfffd9d9d9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: songs.isEmpty
                  ? const Center(child: Text("No songs", style: TextStyle(fontSize: 10)))
                  : Padding(
                      padding: const EdgeInsets.all(4),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                        itemCount: songs.length > 3 ? 4 : songs.length,
                        itemBuilder: (context, index) {
                          if (index == 3 && songs.length > 3) {
                            return Container(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.4),
                              child: const Center(child: Icon(Icons.add, color: Colors.white)),
                            );
                          }
                          final song = songs[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: song['albumArt'] != null
                                ? Image.memory(song['albumArt'], fit: BoxFit.cover)
                                : Container(color: Colors.grey[400], child: const Icon(Icons.music_note)),
                          );
                        },
                      ),
                    ),
            ),
          ),
          if (isCustomPlaylist)
            Positioned(
              top: 4,
              right: 16,
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    userPlaylists.removeWhere((p) => p['name'] == title);
                  });
                  await saveUserPlaylists();
                },
                child: const Icon(Icons.cancel, color: Colors.black),
              ),
            ),
        ],
      ),
      const SizedBox(height: 4),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: "Itim", fontSize: 14)),
    ],
  );
}
}