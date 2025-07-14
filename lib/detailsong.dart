import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';

class DetailSongPage extends StatefulWidget {
  final Map<String, dynamic> song;
  const DetailSongPage({super.key, required this.song});

  @override
  State<DetailSongPage> createState() => _DetailSongPageState();
}

class _DetailSongPageState extends State<DetailSongPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isModalOpen = false;
  String? _previewUrl;

  @override
  void initState() {
    super.initState();
    _loadPreview();

  }
Future<void> _loadPreview() async {
  _previewUrl = widget.song['preview'];
  if (_previewUrl != null && _previewUrl!.isNotEmpty) {
  try {
    await _player.setUrl(_previewUrl!);
    _player.play();
  } catch (e) {
    debugPrint("Error loading preview: $e");
    // fallback to Deezer
    _preloadPreviewFromDeezer();
  }
} else {
  _preloadPreviewFromDeezer();
}
}
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _preloadPreviewFromDeezer() async {
    final title = widget.song['title']?.toLowerCase() ?? '';
    final artist = widget.song['artist']?.toLowerCase() ?? '';
    final query = "$title $artist";
    final deezerApi = 'https://api.deezer.com/search?q=${Uri.encodeComponent(query)}';

    try {
      final response = await http.get(Uri.parse(deezerApi));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['data'] as List;

        final bestMatch = candidates.firstWhere(
          (t) =>
              (t['title'] ?? '').toLowerCase() == title &&
              (t['artist']?['name'] ?? '').toLowerCase() == artist,
          orElse: () => candidates.isNotEmpty ? candidates[0] : null,
        );

        if (bestMatch != null && bestMatch['preview'] != null) {
          _previewUrl = bestMatch['preview'];
          await _player.setUrl(_previewUrl!);
        }
      }
    } catch (e) {
      debugPrint("Preview preload error: $e");
    }
  }

  void _launchSpotifyPlayStore() async {
    const url = 'https://play.google.com/store/apps/details?id=com.spotify.music';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot open Play Store")),
      );
    }
  }

  Future<void> _showPreviewPlayer(BuildContext context) async {
    if (_isModalOpen || _previewUrl == null) return;
    _isModalOpen = true;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey[300],
      isDismissible: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future.delayed(Duration.zero, () {
              _player.play();
            });

            return StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.song['title'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Itim"),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.black),
                            onPressed: () {
                              _player.stop();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<Duration>(
                        stream: _player.positionStream,
                        builder: (context, snap) {
                          final pos = snap.data ?? Duration.zero;
                          final dur = _player.duration ?? const Duration(seconds: 30);
                          final progress = dur.inMilliseconds > 0
                              ? pos.inMilliseconds / dur.inMilliseconds
                              : 0.0;

                          return Column(
                            children: [
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(pos),
                                      style: const TextStyle(fontFamily: "Itim")),
                                  Text(_formatDuration(dur),
                                      style: const TextStyle(fontFamily: "Itim")),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _player.stop();
      _isModalOpen = false;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final duration = ((widget.song['duration'] ?? 0) / 60000).toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Song Detail", style: TextStyle(color: Colors.black, fontFamily: "Itim")),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Divider(thickness: 1.5),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.song['albumArt'] ?? '',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                // ignore: unnecessary_underscores
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  width: 120,
                  color: Colors.grey,
                  child: const Icon(Icons.music_note, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.song['title'] ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.song['artist'] ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),
            Text("Album: ${widget.song['album'] ?? 'Unknown'}"),
            Text("Release Date: ${widget.song['releaseDate'] ?? 'Unknown'}"),
            Text("Duration: $duration min"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _previewUrl == null
                  ? null
                  : () => _showPreviewPlayer(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: Colors.black),
              ),
              child: const Text("Preview",
                  style: TextStyle(fontFamily: 'Itim', color: Colors.black)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Listen to the full track on Spotify. Discover more music and explore artist albums.",
              style: TextStyle(fontSize: 13, fontFamily: "Itim"),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _launchSpotifyPlayStore,
              icon: Image.asset("assets/icons/spotify.png", width: 24, height: 24),
              label: const Text("Spotify", style: TextStyle(fontFamily: "Itim", fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
