import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:tunecrate/generated/app_localizations.dart';
import 'package:tunecrate/globals.dart';
import 'dart:convert';
import 'detailsong.dart';
import 'explore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'category_detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();

  // preload helper
  // ignore: library_private_types_in_public_api
  static final _ExplorePageState globalInstance = _ExplorePageState._();
  static Future<void> preload() async {
    await globalInstance._initAndFetch();
  }
}

class _ExplorePageState extends State<ExplorePage> {
  List<dynamic> allSongs = [];
  Map<String, List<dynamic>> categorizedSongs = {};
  static Map<String, List<dynamic>> _cachedCategorizedSongs = {};
  static List<dynamic> _cachedAllSongs = [];
  String searchQuery = '';
  bool isLoading = true;
  String accessToken = '';

  _ExplorePageState._(); // singleton
  _ExplorePageState(); // default

  final Map<String, List<String>> expandedCategories = {
    'Trending Now': ['trending'],
    'Most Streamed': ['hot+hits'],
    'New Releases': ['new+music'],
    'Popular Songs': ['popular+tracks'],
    'Romantic Songs': ['romantic+songs'],
    'Indian Songs': ['indian+music'],
    'Sad Songs': ['sad+songs'],
    'Old Songs': ['old+hits']
  };

  final String clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
final String clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;


  @override
  void initState() {
    super.initState();
    _loadFromService();
    _initAndFetch();
  }
Future<void> _loadFromService() async {
    await ExploreService().preload();
    setState(() {
      categorizedSongs = ExploreService().categorizedSongs;
      allSongs = ExploreService().allSongs;
      isLoading = false;
    });
  }
  Future<void> _initAndFetch() async {
    if (_cachedCategorizedSongs.isNotEmpty && _cachedAllSongs.isNotEmpty) {
      categorizedSongs = _cachedCategorizedSongs;
      allSongs = _cachedAllSongs;
      setState(() => isLoading = false);
    } else {
      accessToken = await _getSpotifyToken();
      await fetchAllCategories();
       final prefs = await SharedPreferences.getInstance();
    final shouldNotify = prefs.getBool('notifications') ?? true;
    if (shouldNotify) {
      await _notifyTopTrending();
      await _notifyNewReleases();
    }
  }
}

  Future<String> _getSpotifyToken() async {
    final creds = base64Encode(utf8.encode('$clientId:$clientSecret'));
    final resp = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $creds',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );
    final data = json.decode(resp.body);
    return data['access_token'];
  }
Future<void> _notifyTopTrending() async {
  final trendingSongs = categorizedSongs['Trending Now'] ?? [];

  for (int i = 0; i < trendingSongs.length.clamp(0, 3); i++) {
    final song = trendingSongs[i];
    final title = song['name'];
    final artist = (song['artists'] as List).map((a) => a['name']).join(', ');

    Fluttertoast.showToast(
  msg: '🔥 $title by $artist is on fire!',
  toastLength: Toast.LENGTH_SHORT,
  gravity: ToastGravity.BOTTOM,
  backgroundColor: Colors.black87,
  textColor: Colors.white,
  fontSize: 16.0,
);
  }
}

Future<void> _notifyNewReleases() async {
  final newSongs = categorizedSongs['New Releases'] ?? [];

  for (int i = 0; i < newSongs.length.clamp(0, 2); i++) {
    final song = newSongs[i];
    final title = song['name'];
    final artist = (song['artists'] as List).map((a) => a['name']).join(', ');

    Fluttertoast.showToast(
  msg: '🔥 $title by $artist is on fire!',
  toastLength: Toast.LENGTH_SHORT,
  gravity: ToastGravity.BOTTOM,
  backgroundColor: Colors.black87,
  textColor: Colors.white,
  fontSize: 16.0,
);
  }
}
Future<String> translateText(String text, String targetLang) async {
  try {
    final response = await http.post(
      Uri.parse('https://libretranslate.de/translate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': text,
        'source': 'auto',
        'target': targetLang,
        'format': 'text',
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['translatedText'] ?? text;
    } else {
      debugPrint("Translation failed with status: ${response.statusCode}");
      return text; // fallback to original name
    }
  } catch (e) {
    debugPrint("Translation error: $e");
    return text; // fallback on error
  }
}



  Future<void> fetchAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
final selectedLang = prefs.getString('selected_lang') ?? 'en';
    final futures = expandedCategories.entries.map((entry) async {
      List<dynamic> tracksList = [];
      for (final keyword in entry.value) {
        final url =
            'https://api.spotify.com/v1/search?q=${Uri.encodeComponent(keyword)}&type=track&limit=15&offset=30';
        final resp = await http.get(Uri.parse(url), headers: {
          'Authorization': 'Bearer $accessToken',
        });
        if (resp.statusCode == 200) {
          final items = json.decode(resp.body)['tracks']['items'] as List;
          for (var item in items) {
      final originalName = item['name'];
       if (shouldTranslateSong(selectedLang)) {
      final translatedName = await translateText(originalName, selectedLang);
      item['name_translated'] = translatedName;
       } else {
    item['name_translated'] = originalName;
  }
    }
          tracksList.addAll(items);
        }
      }
      final uniq = {
        for (var t in tracksList) t['id']: t
      }.values.toList();
      categorizedSongs[entry.key] = uniq;
      allSongs.addAll(uniq);
    });
    await Future.wait(futures);
    _cachedCategorizedSongs = categorizedSongs;
    _cachedAllSongs = allSongs;
    setState(() => isLoading = false);
    await _notifyTopTrending();
    await _notifyNewReleases();
  }

Future<void> performSearch(String query) async {
  setState(() {
    searchQuery = query;
    isLoading = true;
  });

  if (query.trim().isEmpty) {
    setState(() {
      isLoading = false;
      allSongs = _cachedAllSongs;
    });
    return;
  }

  final url =
      'https://api.spotify.com/v1/search?q=${Uri.encodeComponent(query)}&type=track&limit=30';
  final resp = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $accessToken',
  });

 if (resp.statusCode == 200) {
  final items = json.decode(resp.body)['tracks']['items'] as List;
  final prefs = await SharedPreferences.getInstance();
  final selectedLang = prefs.getString('selected_lang') ?? 'en';

if (shouldTranslateSong(selectedLang)) {
      await Future.wait(items.map((item) async {
        final originalName = item['name'];
        final translatedName = await translateText(originalName, selectedLang);
        item['name_translated'] = translatedName;
      }));
    } else {
      for (var item in items) {
        item['name_translated'] = item['name'];
      }
    }

    setState(() {
      allSongs = items;
      isLoading = false;
    });
  } else {
    setState(() => isLoading = false);
  }
}



  void _onSongTap(dynamic track) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSongPage(song: {
          'title': track['name'] ?? '',
          'artist': (track['artists'] as List).map((a) => a['name']).join(', '),
          'album': track['album']['name'] ?? '',
          'releaseDate': track['album']['release_date'] ?? '',
          'duration': track['duration_ms'] ?? 0,
          'albumArt': track['album']['images'][0]['url'] ?? '',
          'preview': track['preview_url'] ?? '',
          'spotify_url': track['external_urls']['spotify'] ?? '',
        }),
      ),
    );
  }
String translateCategory(String title) {
  final loc = AppLocalizations.of(context);
  switch (title) {
    case 'Trending Now': return loc?.trendingNow ?? title;
    case 'Most Streamed': return loc?.mostStreamed ?? title;
    case 'New Releases': return loc?.newReleases ?? title;
    case 'Popular Songs': return loc?.popularsong ?? title;
    case 'Romantic Songs': return loc?.romanticsong ?? title;
    case 'Indian Songs': return loc?.indiansong ?? title;
    case 'Sad Songs': return loc?.sadsong ?? title;
    case 'Old Songs': return loc?.oldsong ?? title;
    default: return title;
  }
}
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text(loc?.explore ??"Explore", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              const Divider(thickness: 1.5, indent: 40, endIndent: 40),
              Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  child: Container(
    height: 40,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      // ignore: deprecated_member_use
      color: const Color(0xFFE6E1E1).withOpacity(0.57),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: performSearch,
            decoration: InputDecoration(
              hintText: loc?.searchhere ??'Search here',
              hintStyle: const TextStyle(fontFamily: "Itim"),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            ),
          ),
        ),
        const VerticalDivider(
          color: Colors.grey,
          thickness: 2,
          indent: 8,
          endIndent: 8,
        ),
        const SizedBox(width: 5),
        Image.asset(
          'assets/icons/equalizer.png',
          width: 24,
          height: 24,
          color: Colors.grey,
        ),
        const SizedBox(width: 10),
      ],
    ),
  ),
),

              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (searchQuery.isNotEmpty
                        ? buildSearchResults(allSongs)
                        : ListView(
                            children: expandedCategories.keys.map((key) {
                              final songs = categorizedSongs[key] ?? [];
                              return buildSongCategory(key, songs);
                            }).toList(),
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSongCategory(String title, List<dynamic> songs) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryDetailPage(title: title,
                keyword: expandedCategories[title]!.first,),
              ),
            );
          },
          child: Text(translateCategory(title), style: const TextStyle(fontFamily: "Itim", fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: songs.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final track = songs[index];
              final imageUrl = (track['album']?['images'] as List?)?.firstOrNull?['url'];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => _onSongTap(track),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl != null
                            ? Image.network(imageUrl, height: 120, width: 100, fit: BoxFit.cover)
                            : Container(height: 120, width: 100, color: Colors.grey[400], child: const Icon(Icons.music_note)),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                         track['name_translated'] ?? track['name'] ?? '',
                          style: const TextStyle(fontFamily: "Itim", fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget buildSearchResults(List<dynamic> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final track = results[index];
        final imageUrl = (track['album']?['images'] as List?)?.firstOrNull?['url'];
        return ListTile(
          leading: imageUrl != null
              ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
              : Container(width: 50, height: 50, color: Colors.grey, child: const Icon(Icons.music_note)),
          title: Text(track['name_translated'] ??track['name'] ?? '', style: const TextStyle(fontFamily: "Itim", fontSize: 14)),
          onTap: () => _onSongTap(track),
        );
      },
    );
  }
}
