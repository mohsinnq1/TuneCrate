// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tunecrate/generated/app_localizations.dart';
import 'package:tunecrate/globals.dart';
import 'package:tunecrate/playercontroller.dart';
import 'main.dart';
import 'firebase_options.dart';
import 'fetch_songs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await [
    Permission.storage,
    Permission.audio,
  ].request();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

await loadPlayCounts();
  // Fetch songs once
  globalSongs = await fetchAllSongs();
  final prefs = await SharedPreferences.getInstance();
final favPaths = prefs.getStringList('favorites') ?? [];
final recentPaths = prefs.getStringList('recent_played') ?? [];
final mostPaths = prefs.getStringList('most_played') ?? [];

final savedPlaylists = prefs.getString('user_playlists');
if (savedPlaylists != null) {
  final decoded = jsonDecode(savedPlaylists);
  userPlaylists = List<Map<String, dynamic>>.from(decoded.map((p) {
    final name = p['name'];
    final paths = List<String>.from(p['songs']);
    final songs = globalSongs.where((s) => paths.contains(s['file'].path)).toList();
    return {'name': name, 'songs': songs};
  }));
}

favouriteSongs.clear();  // 👈 clear first
for (final path in favPaths) {
  final match = globalSongs.where((s) => s['file'].path == path);
  if (match.isNotEmpty) {
    favouriteSongs.add(match.first);
  }
}
for (final path in recentPaths) {
  final match = globalSongs.where((s) => s['file'].path == path);
  if (match.isNotEmpty) {
    PlayerController().recentPlayed.add(match.first);
  }
}
for (final path in mostPaths) {
  final match = globalSongs.where((s) => s['file'].path == path);
  if (match.isNotEmpty) {
    PlayerController().mostPlayed.add(match.first);
  }
}

// restore last playing:
final lastPath = prefs.getString('last_playing');
if (lastPath != null) {
  final match = globalSongs.where((s) => s['file'].path == lastPath);
  if (match.isNotEmpty) {
    PlayerController().currentSong = match.first;
  }
}
  bool isFirstTime = prefs.getBool('first_time') ?? true;
  String langCode = prefs.getString('lang') ?? 'en';

  runApp(
    ChangeNotifierProvider(
      create: (_) => PlayerController(),
      child: TuneCrateApp(isFirstTime: isFirstTime, locale: Locale(langCode)),
    ),
  );
}

class TuneCrateApp extends StatelessWidget {
  final bool isFirstTime;
  final Locale locale;

  const TuneCrateApp({super.key, required this.isFirstTime, required this.locale});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
        Locale('ar'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: isFirstTime ? const SplashScreen() : HomePage(songs: globalSongs),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _onGetStarted(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(songs: globalSongs),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAEAEA), Color(0xFFBFD4E3)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              
              mainAxisSize: MainAxisSize.min,
              children: [
  Row(
    mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        'assets/icons/musicnote.png',
        width: 45,
        height: 45,
        color: Colors.black,
      ),
      const Text(
        'TuneCrate',
        style: TextStyle(
          fontFamily: 'Itim',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    ],
  ),
  const SizedBox(height: 16),
  Text(
    loc?.splashDescription ??
        'Hey there, Music Lover!\nDive into your tunes, favorite your jams,\nand discover more with TuneCrate.',
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontFamily: 'Itim',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
  ),
  const SizedBox(height: 56),
  ElevatedButton(
    onPressed: () => _onGetStarted(context),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3E6472),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: Text(
      loc?.getStarted ?? 'Get Started',
      style: const TextStyle(
        fontFamily: 'Itim',
        fontSize: 20,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
],

            ),
          ),
        ),
      ),
    );
  }
}
