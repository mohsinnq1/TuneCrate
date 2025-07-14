import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';

// ---- GLOBAL PlayerController ----
class PlayerController extends ChangeNotifier {
  static final PlayerController _instance = PlayerController._internal();
  factory PlayerController() => _instance;
  PlayerController._internal();

  final AudioPlayer player = AudioPlayer();
  int _currentIndexInList = 0;
  Map<String,dynamic>? currentSong;
  List<Map<String, dynamic>> _playlist = [];
  List<Map<String, dynamic>> recentPlayed = [];
  List<Map<String, dynamic>> mostPlayed = [];
bool isPlaying = false;
  int currentIndex = 0;

void setPlaylist(List<Map<String, dynamic>> songs) {
  _playlist = songs;
  _currentIndexInList = 0;
  notifyListeners();
}
 Future<void> loadPlayCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('play_counts') ?? [];
    for (var entry in stored) {
      final parts = entry.split('|');
      if (parts.length == 2) {
        final path = parts[0];
        final count = int.tryParse(parts[1]) ?? 0;
        playCounts[path] = count;
      }
    }
  }

  Future<void> savePlayCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final stored =
        playCounts.entries.map((e) => '${e.key}|${e.value}').toList();
    prefs.setStringList('play_counts', stored);
  }
void setSong(Map<String, dynamic> song) async {
  currentSong = song;
  final path = song['file'].path;

  // 1. Update play count
  playCounts[path] = (playCounts[path] ?? 0) + 1;
  await savePlayCounts();

  // 2. Build mostPlayed list
  final uniqueSongs = {
    for (var s in _playlist) s['file'].path: s,
  };

  final sortedEntries = (playCounts.entries)
    .where((e) => uniqueSongs.containsKey(e.key) && e.value >= 3)
    .toList()
  ..sort((a, b) => b.value.compareTo(a.value));
  mostPlayed = sortedEntries
    .map((e) => uniqueSongs[e.key]!)
    .take(50)
    .toList();
  // 3. Update recentPlayed
  _currentIndexInList = _playlist.indexWhere((s) => s['file'].path == path);
  if (!recentPlayed.any((s) => s['file'].path == path)) {
    recentPlayed.insert(0, song);
  } else {
    recentPlayed.removeWhere((s) => s['file'].path == path);
    recentPlayed.insert(0, song);
  }
  if (recentPlayed.length > 50) {
    recentPlayed.removeLast();
  }

  // 4. Save preferences
  final prefs = await SharedPreferences.getInstance();
  prefs.setStringList(
    'recent_played',
    recentPlayed.map((s) => s['file']?.path).whereType<String>().toList(),
  );
  prefs.setStringList(
    'most_played',
    mostPlayed.map((s) => s['file']?.path).whereType<String>().toList(),
  );
  prefs.setString('last_playing', path);

  // 5. Play the song
  try {
    await player.setFilePath(path);
    play();
  } catch (e) {
    debugPrint("Error: $e");
  }

  notifyListeners();
}


  void play() {
    player.play();
    isPlaying = true;
    notifyListeners();
  }

  void pause() {
    player.pause();
    isPlaying = false;
    notifyListeners();
  }
  void nextSong() {
  if (_playlist.isEmpty) return;
  _currentIndexInList = (_currentIndexInList + 1) % _playlist.length;
    setSong(_playlist[_currentIndexInList]);
  
}

void previousSong() {
  if (_playlist.isEmpty) return;
   _currentIndexInList = (_currentIndexInList - 1 + _playlist.length) % _playlist.length;
    setSong(_playlist[_currentIndexInList]);
}
}