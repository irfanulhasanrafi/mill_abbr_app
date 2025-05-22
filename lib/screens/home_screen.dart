import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/abbreviation.dart';
import 'favorites_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  HomeScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Abbreviation> allAbbrs = [];
  List<Abbreviation> filteredAbbrs = [];
  Set<String> favoriteAbbrs = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadAbbreviations();
    loadFavorites();
  }

  Future<void> loadAbbreviations() async {
    final jsonStr = await rootBundle.loadString('assets/abbreviations.json');
    final List<dynamic> data = json.decode(jsonStr);
    setState(() {
      allAbbrs = data.map((e) => Abbreviation.fromJson(e)).toList();
      filteredAbbrs = allAbbrs;
    });
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteAbbrs = (prefs.getStringList('favorites') ?? []).toSet();
    });
  }

  Future<void> toggleFavorite(String abbr) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteAbbrs.contains(abbr)) {
        favoriteAbbrs.remove(abbr);
      } else {
        favoriteAbbrs.add(abbr);
      }
      prefs.setStringList('favorites', favoriteAbbrs.toList());
    });
  }

  void _filter(String query) {
    _searchQuery = query.toLowerCase();

    List<Abbreviation> exactAbbrMatches = [];
    List<Abbreviation> partialAbbrMatches = [];
    List<Abbreviation> exactFullFormMatches = [];
    List<Abbreviation> partialFullFormMatches = [];

    for (var abbr in allAbbrs) {
      final abbrLower = abbr.abbr.toLowerCase();
      final fullFormLower = abbr.fullForm.toLowerCase();

      if (abbrLower == _searchQuery) {
        exactAbbrMatches.add(abbr);
      } else if (abbrLower.contains(_searchQuery)) {
        partialAbbrMatches.add(abbr);
      } else if (fullFormLower == _searchQuery) {
        exactFullFormMatches.add(abbr);
      } else if (fullFormLower.contains(_searchQuery)) {
        partialFullFormMatches.add(abbr);
      }
    }

    setState(() {
      filteredAbbrs = [
        ...exactAbbrMatches,
        ...partialAbbrMatches,
        ...exactFullFormMatches,
        ...partialFullFormMatches,
      ];
    });
  }

  Widget highlightText(String text, String query, BuildContext context) {
    if (query.isEmpty) return Text(text);

    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final start = lower.indexOf(q);
    if (start == -1) return Text(text);

    final end = start + query.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RichText(
      text: TextSpan(
        text: text.substring(0, start),
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        children: [
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              backgroundColor: isDark ? Colors.tealAccent : Colors.yellow,
              color: isDark ? Colors.black : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: text.substring(end),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mill Abbr'),
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoritesScreen(
                        allAbbrs: allAbbrs, favoriteAbbrs: favoriteAbbrs),
                  ));
            },
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AboutScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredAbbrs.length,
              itemBuilder: (_, index) {
                final abbr = filteredAbbrs[index];
                return ListTile(
                  title: highlightText(abbr.abbr, _searchQuery, context),
                  subtitle: highlightText(abbr.fullForm, _searchQuery, context),
                  trailing: IconButton(
                    icon: Icon(
                      favoriteAbbrs.contains(abbr.abbr)
                          ? Icons.star
                          : Icons.star_border,
                      color: favoriteAbbrs.contains(abbr.abbr)
                          ? Colors.amber
                          : null,
                    ),
                    onPressed: () => toggleFavorite(abbr.abbr),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
