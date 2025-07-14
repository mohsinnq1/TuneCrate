import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, dynamic>> globalSongs = [];
List<Map<String, dynamic>> userPlaylists = [];
List<Map<String, dynamic>> allSongs = [];
List<Map<String, dynamic>> recentPlayed = [];
List<Map<String, dynamic>> mostPlayed = [];
Map<String, int> playCounts = {};
List<Map<String, dynamic>> favouriteSongs = [];
ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
Future<void> saveUserPlaylists() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    'user_playlists',
    jsonEncode(userPlaylists.map((playlist) => {
      'name': playlist['name'],
      'songs': List<String>.from(
        List<Map<String, dynamic>>.from(playlist['songs']).map((song) => song['file'].path),
      ),
    }).toList()),
  );
}
Future<void> savePlayCounts() async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(playCounts);
  await prefs.setString('play_counts', encoded);
}

Future<void> loadPlayCounts() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = prefs.getString('play_counts');
  if (jsonStr != null) {
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    playCounts = decoded.map((key, value) => MapEntry(key, value as int));
  }
}
bool shouldTranslateSong(String selectedLang) {
  const translateLanguages = {'en', 'ar','fr', 'es','zh', 'hi','bn', 'pt','ru', 'ja','ko', 'de','tr', 'id'};
  return translateLanguages.contains(selectedLang);
}
