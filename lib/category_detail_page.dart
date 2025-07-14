import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detailsong.dart';
import 'package:tunecrate/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryDetailPage extends StatefulWidget {
  final String title;
  final String keyword;
  const CategoryDetailPage({
    super.key,
    required this.title,
    required this.keyword,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<dynamic> songs = [];
  final ScrollController _scrollController = ScrollController();
  int _offset = 0;
  final int _limit = 15;
  bool isLoading = false;
  bool hasMore = true;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _fetchToken();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchToken() async {
    final String clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
final String clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;
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
    _accessToken = data['access_token'];
    _fetchSongs();
  }
Future<String> translateText(String text, String targetLang) async {
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
    return json['translatedText'];
  } else {
    return text;
  }
}

  Future<void> _fetchSongs() async {
    if (isLoading || !hasMore || _accessToken == null) return;
    setState(() => isLoading = true);

    final url =
        'https://api.spotify.com/v1/search?q=${Uri.encodeComponent(widget.keyword)}&type=track&limit=$_limit&offset=$_offset';

    final resp = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $_accessToken',
    });
    if (resp.statusCode == 200) {
      final items = json.decode(resp.body)['tracks']['items'] as List;
      final prefs = await SharedPreferences.getInstance();
final selectedLang = prefs.getString('selected_lang') ?? 'en';

for (var item in items) {
  final originalName = item['name'];
  final translatedName = await translateText(originalName, selectedLang);
  item['name_translated'] = translatedName;
}
      setState(() {
        songs.addAll(items);
        _offset += _limit;
        if (items.length < _limit) hasMore = false;
      });
    }
    setState(() => isLoading = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoading &&
        hasMore) {
      _fetchSongs();
    }
  }

  void _onSongTap(dynamic track) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSongPage(song: {
          'title': track['name'] ?? '',
          'artist': (track['artists'] as List).map((a) => a['name']).join(', '),
          'album': track['album']?['name'] ?? '',
          'releaseDate': track['album']?['release_date'] ?? '',
          'duration': track['duration_ms'] ?? 0,
          'albumArt': (track['album']?['images'] as List?)?.firstOrNull?['url'] ?? '',
          'preview': track['preview_url'] ?? '',
          'spotify_url': track['external_urls']?['spotify'] ?? '',
        }),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(translateCategory(widget.title), style: const TextStyle(color: Colors.black, fontFamily: "Itim")),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: songs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: songs.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < songs.length) {
                    final track = songs[index];
                    final imgUrl = (track['album']?['images'] as List?)?.firstOrNull?['url'];
                    return GestureDetector(
                      onTap: () => _onSongTap(track),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imgUrl != null
                                ? Image.network(imgUrl, height: 100, width: 100, fit: BoxFit.cover)
                                : Container(height: 100, width: 100, color: Colors.grey[400], child: const Icon(Icons.music_note)),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            track['name_translated'] ?? track['name'] ?? '',
                            style: const TextStyle(fontSize: 12, fontFamily: "Itim"),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
    );
  }
}
