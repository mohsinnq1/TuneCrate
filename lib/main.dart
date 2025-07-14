import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunecrate/explore_service.dart';
import 'package:tunecrate/generated/app_localizations.dart';
import 'playlist.dart';
import 'favourite.dart';
import 'guestexplore.dart';
import 'settingspage.dart';
import 'explore.dart';
import 'miniplayer.dart';
import 'globals.dart';
import 'playercontroller.dart';

class HomePage extends StatefulWidget {
  final List<Map<String, dynamic>> songs;
  final int initialIndex;
  const HomePage({super.key, required this.songs, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  List<Map<String, dynamic>> _songs = [];
  List<Map<String, dynamic>> recentPlayed = [];
  String _searchQuery = '';
  final ScrollController _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ExploreService().preload();
    _songs = widget.songs;
    _currentIndex = widget.initialIndex;
    _checkLoginState();
    
     if (_songs.isNotEmpty) {
    _songs.sort((a, b) => a['title']
        .toString()
        .toLowerCase()
        .compareTo(b['title'].toString().toLowerCase()));

    final player = PlayerController();
    player.loadPlayCounts().then((_) {
      player.setPlaylist(_songs);
    });
  }
  
  }
Widget _navIcon(int index, Widget icon, String label) {
  final bool isSelected = _currentIndex == index;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    decoration: isSelected
        ? BoxDecoration(
            color: const Color(0xFF878787),
            borderRadius: BorderRadius.circular(12),
          )
        : null,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}



    void _checkLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  bool logged = prefs.getBool('logged_in') ?? false;
  isLoggedIn.value = logged;
}

  void addToRecentPlayed(Map<String, dynamic> song) {
    if (!recentPlayed.any((s) => s['file'].path == song['file'].path)) {
      recentPlayed.insert(0, song);
      if (recentPlayed.length > 50) recentPlayed.removeLast();
    }
  }

  List<Map<String, dynamic>> _filteredSongs() {
    return _songs.where((song) {
      final title = song['title'].toString().toLowerCase();
      final artist = song['artist'].toString().toLowerCase();
      return _searchQuery.isEmpty ||
          title.contains(_searchQuery) ||
          artist.contains(_searchQuery);
    }).toList();
  }

  void _jumpToLetter(String letter) {
    final index = _filteredSongs().indexWhere(
        (s) => s['title'].toUpperCase().startsWith(letter));
    if (index != -1) {
      _listScrollController.animateTo(
        index * 70,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  

  Widget _buildHomeTab(PlayerController player) {
    final loc = AppLocalizations.of(context);
    final sortedSongs = _filteredSongs();

    return SafeArea(
      child: Container(
        color: const Color(0xFFE2E2E2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('TuneCrate',
                  style: const TextStyle(
                      fontFamily: "Itim",
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            // subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                loc?.subtitle ??
                    "our music universe — offline & \nonline, favorite & fresh.",
                style: const TextStyle(
                  fontFamily: "Itim",
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            // search
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
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: loc?.searchhere ?? "Search here",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 5),
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
                    Image.asset('assets/icons/equalizer.png',
                        width: 24, height: 24, color: Colors.grey),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
            // song list
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _listScrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            itemCount: sortedSongs.length,
                            itemBuilder: (context, index) {
                              final song = sortedSongs[index];
                              final isCurrent = player.currentSong?['file'].path ==
                                  song['file'].path;

                              return GestureDetector(
                                onTap: () {
                                  player.setSong(song);
                                  addToRecentPlayed(song);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: song['albumArt'] != null
                                            ? Image.memory(song['albumArt'],
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover)
                                            : Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey,
                                                child: const Icon(
                                                    Icons.music_note,
                                                    color: Colors.black),
                                              ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    song['title'],
                                                    style: TextStyle(
                                                      fontFamily: "Itim",
                                                      fontSize: 14,
                                                      fontWeight: isCurrent
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  icon: const Icon(
                                                      Icons.more_vert),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  color: Colors.white
                                                      // ignore: deprecated_member_use
                                                      .withOpacity(0.95),
                                                  itemBuilder: (context) {
                                                    return [
                                                      PopupMenuItem<String>(
                                                        enabled: false,
                                                        child:
                                                            PopupMenuButton<
                                                                String>(
                                                          onSelected:
                                                              (playlistName) async {
                                                            try {
                                                              final playlist =
                                                                  userPlaylists
                                                                      .firstWhere((p) =>
                                                                          p['name'] ==
                                                                          playlistName);
                                                              playlist['songs'] ??=
                                                                  [];
                                                              playlist['songs'].add(song);
                                                                  await saveUserPlaylists();
                                                              ScaffoldMessenger.of(
                                                                      // ignore: use_build_context_synchronously
                                                                      context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'Added to $playlistName')),
                                                              );
                                                            } catch (_) {}
                                                          },
                                                          itemBuilder:
                                                              (context) {
                                                            return userPlaylists
                                                                .map((p) =>
                                                                    PopupMenuItem<
                                                                        String>(
                                                                      value: p[
                                                                          'name'],
                                                                      child: Text(
                                                                          p['name']),
                                                                    ))
                                                                .toList();
                                                          },
                                                          child: Row(
                                                            children: const [
                                                              Text(
                                                                  "Add to Playlist",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              Icon(Icons
                                                                  .arrow_drop_down),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ];
                                                  },
                                                ),
                                              ],
                                            ),
                                            Container(
                                                margin:
                                                    const EdgeInsets.only(top: 2),
                                                height: 1,
                                                color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (player.currentSong != null)
                          buildMiniPlayer(
                            context,
                            player.player,
                            player.currentSong ?? _songs[0],
                            player.isPlaying,
                            () {
                              if (player.isPlaying) {
                                player.pause();
                              } else {
                                player.play();
                              }
                            },
                            () => player.nextSong(),
                            () => player.previousSong(),
                          ),
                      ],
                    ),
                  ),
                  // alphabet
                  Container(
                    width: 20,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...[
  loc?.a ?? 'A',
  loc?.b ?? 'B',
  loc?.c ?? 'C',
  loc?.d ?? 'D',
  loc?.e ?? 'E',
  loc?.f ?? 'F',
  loc?.g ?? 'G',
  loc?.h ?? 'H',
  loc?.i ?? 'I',
  loc?.j ?? 'J',
  loc?.k ?? 'K',
  loc?.l ?? 'L',
  loc?.m ?? 'M',
  loc?.n ?? 'N',
  loc?.o ?? 'O',
  loc?.p ?? 'P',
  loc?.q ?? 'Q',
  loc?.r ?? 'R',
  loc?.s ?? 'S',
  loc?.t ?? 'T',
  loc?.u ?? 'U',
  loc?.v ?? 'V',
  loc?.w ?? 'W',
  loc?.x ?? 'X',
  loc?.y ?? 'Y',
  loc?.z ?? 'Z',
].map((letter) {
                            return GestureDetector(
                              onTapDown: (details) {
                                _jumpToLetter(letter);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(letter,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    List<Widget> getPages(bool logged) {
      return [
        Consumer<PlayerController>(
          builder: (context, player, _) => _buildHomeTab(player),
        ),
        PlaylistPage(),
        const FavouritesPage(),
        logged ? const ExplorePage() : const GuestExplore(),
        const SettingsPage(),
      ];
    }

    return Scaffold(
    body: ValueListenableBuilder<bool>(
  valueListenable: isLoggedIn,
  builder: (context, logged, _) {
    final pages = getPages(logged);
    final safeIndex = _currentIndex.clamp(0, pages.length - 1);
    return pages[safeIndex];
  },
),


  bottomNavigationBar: BottomNavigationBar(
  backgroundColor: const Color(0xFFC8C7C7),
  selectedItemColor: Colors.black,
  unselectedItemColor: Colors.black54,
  type: BottomNavigationBarType.fixed,
  currentIndex: _currentIndex,
  onTap: (index) async {
    setState(() => _currentIndex = index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_tab', index);
  },
  iconSize: 24, // Reduce icon size slightly
  selectedFontSize: 10, // Reduce text size slightly
  unselectedFontSize: 10,
  items: [
    BottomNavigationBarItem(
      icon: _navIcon(0, Image.asset("assets/icons/Home.png", width: 24, height: 24, color: Colors.black), loc?.home ?? 'Home'),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _navIcon(1, Image.asset("assets/icons/playlist.png", width: 24, height: 24, color: Colors.black), loc?.playlist ?? 'Playlist'),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _navIcon(2, const Icon(Icons.favorite, color: Colors.black), loc?.favorites ?? 'Favorites'),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _navIcon(3, const Icon(Icons.explore, color: Colors.black), loc?.explore ?? 'Explore'),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _navIcon(4, const Icon(Icons.settings, color: Colors.black), loc?.settings ?? 'Settings'),
      label: '',
    ),
  ],
),

    );
  }
}