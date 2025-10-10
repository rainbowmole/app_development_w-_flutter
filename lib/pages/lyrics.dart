String LyricPrototype = """
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ShowLyrics extends StatefulWidget{
  final String songTitle;
  final String artistName;

  ShowLyrics ({
    required this.songTitle,
    required this.artistName,
  });

  @override
  State<ShowLyrics> createState() => _ShowLyricsState(){
}

class _ShowLyricsState extends State<ShowLyrics> {
  late Future<String> _lyricsFuture;

  @override
  void initState() {
    super.initState();
    _lyricsFuture = fetchLyrics(widget.artistName, widget.songTitle);
  }

  Future<String> fetchLyrics(artistName, songTitle) async {
    final url = Uri.parse('https://api.lyrics.ovh/v1/artistName/songTitle');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['lyrics'] ?? 'Lyrics not found.';
    } else {
      return 'Failed to fetch lyrics.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _lyricsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Error loading lyrics'),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(
                snapshot.data ?? 'Lyrics not found.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }
      },
    );
  }
}
""";
