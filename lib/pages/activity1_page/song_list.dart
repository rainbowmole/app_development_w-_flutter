import 'package:flutter/material.dart';

class SongListWidget extends StatefulWidget {
  final List<String> songs;
  final List<String> cover;
  final double listHeight;
  final int currentIndex;
  final Function(int) onSongSelected;

  const SongListWidget({
    super.key,
    required this.songs,
    required this.cover,
    required this.listHeight,
    required this.currentIndex,
    required this.onSongSelected,
  });

  @override
  _SongListWidgetState createState() => _SongListWidgetState();
}

class _SongListWidgetState extends State<SongListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      //constraints: const BoxConstraints(maxWidth: 400, maxHeight: 675),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 10, 32, 70), width: 2),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Your Library',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ),
          const Divider(color: Colors.white24),
          Flexible(
            child: SizedBox(
              height: widget.listHeight,
                child:Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                  itemCount: widget.songs.length, 
                  itemBuilder: (context, index){
                    String songfile = widget.songs[index].split("/").last.replaceAll(".mp3", "");
                    List<String> parts = songfile.split(" - ");
                    String songTitle = parts[0];
                    String artistName = parts.length > 1 ? parts[1] : "Unknown Artist";

                    bool isOn = index == widget.currentIndex;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Material(
                          color: isOn ? const Color.fromARGB(255, 64, 68, 75) : Colors.transparent,
                          child: ListTile(
                            selected: isOn,
                            selectedTileColor: const Color.fromARGB(255, 64, 68, 75),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset(
                                widget.cover[index % widget.cover.length],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.music_note, size: 40, color: Colors.blueGrey);
                                },
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  songTitle,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  artistName,
                                  style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                                ),
                              ],
                            ), 
                            onTap: () => widget.onSongSelected(index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SongListPage extends StatelessWidget{
  final List<String> songs;
  final List<String> cover;
  final Function(int) onSongSelected;

  const SongListPage({
    super.key, 
    required this.songs, 
    required this.cover, 
    required this.onSongSelected
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Song list')),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index){
          String songfile = songs[index].split("/").last.replaceAll(".mp3", "");
          List<String> parts = songfile.split(" - "); //[0 = song title, 1 = artist]
          String songTitle = parts[0];
          String artistName = parts.length > 1 ? parts[1] : "Unknown Artist";
          
          Widget ListCover = Image.asset(
            cover[index % cover.length],
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.accessibility, size: 200, color: Colors.blueGrey);
                    },
          );

          return ListTile(
            leading: ListCover,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  songTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  artistName,
                  style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
              ],
            ), 
            onTap: () => onSongSelected(index),
          );
        }
      ),
    );
  }
}

