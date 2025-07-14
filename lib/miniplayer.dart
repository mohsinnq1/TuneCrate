import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:tunecrate/playercontroller.dart';
import 'detail.dart';

Widget buildMiniPlayer(
  BuildContext context,
  AudioPlayer player,
  Map<String, dynamic>? song,  // nullable
  bool isPlaying,
  VoidCallback onPlayPause,
  VoidCallback onNext,
  VoidCallback onPrevious,
) {
  return Consumer<PlayerController>(
    builder: (context, playerController, _) {
      final currentSong = playerController.currentSong;
      final isPlaying = playerController.isPlaying;

      return GestureDetector(
        onTap: () {
          if (currentSong != null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              // ignore: use_full_hex_values_for_flutter_colors
              backgroundColor: const Color(0xfff898181),
              builder: (_) {
                return FractionallySizedBox(
                  heightFactor: 0.7,
                  child: NowPlayingDetailPage(),
                );
              },
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 20,
                  child: Marquee(
                    text: currentSong != null
                        ? "${currentSong['title']} - ${currentSong['artist']}"
                        : 'Nothing playing',
                    style: const TextStyle(color: Colors.white),
                    blankSpace: 40,
                    velocity: 30,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: currentSong != null ? playerController.previousSong : null,
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: currentSong != null
                    ? () {
                        if (isPlaying) {
                          playerController.pause();
                        } else {
                          playerController.play();
                        }
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: currentSong != null ? playerController.nextSong : null,
              ),
            ],
          ),
        ),
      );
    },
  );
}
