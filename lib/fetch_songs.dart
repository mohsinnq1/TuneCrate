import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

Future<List<Map<String, dynamic>>> fetchAllSongs() async {
  Directory musicDir = Directory('/storage/emulated/0/Music');
  if (!musicDir.existsSync()) {
    musicDir = Directory('/storage/emulated/0/Download');
  }

  final files = musicDir.listSync(recursive: true);
  final paths = files
      .whereType<File>()
      .where((f) => f.path.endsWith('.mp3') || f.path.endsWith('.m4a'))
      .map((f) => f.path)
      .toList();

  return compute(loadSongs, paths);
}

Future<List<Map<String, dynamic>>> loadSongs(List<String> paths) async {
  List<Map<String, dynamic>> songs = [];

  for (String path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;

    try {
      final metadata = await MetadataRetriever.fromFile(file);
      songs.add({
        'file': file,
        'title': metadata.trackName ?? file.path.split('/').last,
        'artist': metadata.trackArtistNames?.join(', ') ?? 'Unknown Artist',
        'albumArt': metadata.albumArt,
      });
    } catch (_) {
      songs.add({
        'file': file,
        'title': file.path.split('/').last,
        'artist': 'Unknown Artist',
        'albumArt': null,
      });
    }
  }

  return songs;
}
