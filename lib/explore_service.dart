import 'package:http/http.dart' as http;
import 'dart:convert';

class ExploreService {
  static final ExploreService _instance = ExploreService._internal();
  factory ExploreService() => _instance;
  ExploreService._internal();

  Map<String, List<dynamic>> categorizedSongs = {};
  List<dynamic> allSongs = [];
  bool _initialized = false;

  final Map<String, List<String>> categories = {
    'Trending Now': ['trending'],
    'Most Streamed': ['hot+hits'],
    'New Releases': ['new+music'],
    'Popular Songs': ['popular+tracks'],
    'Romantic Songs': ['romantic+songs'],
    'Indian Songs': ['indian+music'],
    'Sad Songs': ['sad+songs'],
    'Old Songs': ['old+hits'],
  };

  final String clientId = '55e4f67552a9487aa2cb840da64feb76';
  final String clientSecret = '9e0c928ce6094584aeeb5111602003a5';
  String? _accessToken;

  Future<void> preload() async {
    if (_initialized) return;

    // get token
    final creds = base64Encode(utf8.encode('$clientId:$clientSecret'));
    final tokenResp = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $creds',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );
    final tokenData = json.decode(tokenResp.body);
    _accessToken = tokenData['access_token'];

    // get all categories
    final futures = categories.entries.map((entry) async {
      List<dynamic> tracksList = [];
      for (final keyword in entry.value) {
        final url =
            'https://api.spotify.com/v1/search?q=${Uri.encodeComponent(keyword)}&type=track&limit=15&offset=30';
        final resp = await http.get(Uri.parse(url), headers: {
          'Authorization': 'Bearer $_accessToken',
        });
        if (resp.statusCode == 200) {
          final items = json.decode(resp.body)['tracks']['items'] as List;
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

    _initialized = true;
  }
}
