import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/abbreviation.dart';
import '../utils/pdf_helper.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Abbreviation> allAbbrs;
  final Set<String> favoriteAbbrs;

  FavoritesScreen({required this.allAbbrs, required this.favoriteAbbrs});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Abbreviation> filteredFavorites = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filter('');
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query;
      filteredFavorites = widget.allAbbrs
          .where((abbr) =>
              widget.favoriteAbbrs.contains(abbr.abbr) &&
              (abbr.abbr.toLowerCase().contains(query.toLowerCase()) ||
                  abbr.fullForm.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  Future<void> exportFavoritesToPdf() async {
    var status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: filteredFavorites.map((abbr) {
                return pw.Text('${abbr.abbr} : ${abbr.fullForm}');
              }).toList(),
            );
          },
        ),
      );

      final bytes = await pdf.save();

      // Save directly to Downloads folder
      final file = File('/storage/emulated/0/Download/mill abbr favorites.pdf');
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to Downloads folder!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied. Cannot save PDF.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Favorites...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0)),
              ),
              onChanged: _filter,
            ),
          ),
          ElevatedButton(
            onPressed: exportFavoritesToPdf,
            child: Text('Export Favorites to PDF'),
          ),
          Expanded(
            child: filteredFavorites.isEmpty
                ? Center(child: Text('No favorites yet'))
                : ListView.builder(
                    itemCount: filteredFavorites.length,
                    itemBuilder: (_, index) {
                      final abbr = filteredFavorites[index];
                      return ListTile(
                        title: Text(abbr.abbr),
                        subtitle: Text(abbr.fullForm),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
