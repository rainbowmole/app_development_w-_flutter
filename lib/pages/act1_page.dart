import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

import 'package:flutter/services.dart';

class ActivityPage1 extends StatefulWidget {
  const ActivityPage1({super.key});

  @override
  _YourMusicPlayer createState() => _YourMusicPlayer();
}

class _YourMusicPlayer extends State<ActivityPage1>{
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _playPause = false;
  bool _isShuffle = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  List<String> songs = [
    "assets/music/AEAO.mp3",
    "assets/music/HER.mp3",
    "assets/music/Swim.mp3",
    "assets/music/WallToWall.mp3",
    "assets/music/Often.mp3",
    "assets/music/Paradise.mp3",
    "assets/music/BeatIt.mp3",
    "assets/music/SlowDown.mp3",
    "assets/music/Starboy.mp3",
    "assets/music/SugarOnMyTongue.mp3",
    "assets/music/AllIWannaDo.mp3"

  ];

  List<String> cover = [
    "assets/cover/1.jpg",
    "assets/cover/2.jpg",
    "assets/cover/3.jpg",
    "assets/cover/4.jpg",
    "assets/cover/5.jpg",
    "assets/cover/6.jpg",
    "assets/cover/7.jpg",
    "assets/cover/8.jpg",
    "assets/cover/9.jpg",
    "assets/cover/minji.jpg",
    "assets/cover/11.jpg",
  ];

  Future<void> _playSong(int index) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(songs[index].replaceFirst("assets/", "")));
    setState(() {
      _currentIndex = index;
      _isPlaying = true;
      _playPause = false;
    });
  }

  Future<void> _togglePlayPause() async {
    _isPlaying ? await _audioPlayer.pause() : await _audioPlayer.resume();
    setState(() {
      _isPlaying = !_isPlaying;
      _playPause = !_playPause;
    });
  }

  void _nextSong(){
    if (_isShuffle) { 
      _shuffleSong();
    }else{
      int i = (_currentIndex + 1) % songs.length;
      _playSong(i);
    }
  }
  
  void _prevSong(){
    int i = (_currentIndex - 1 + songs.length) % songs.length;
    _playSong(i);
  }

  void _shuffleSong(){
    int i;
    do {
      i = Random().nextInt(songs.length);
    } while (i == _currentIndex && songs.length > 1);
    _playSong(i);
  }

  String _formatTime(Duration d){
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  bool _controlKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space){
        _togglePlayPause();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight){
        _nextSong();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft){
        _prevSong();
        return true;
      }
    }
    return false;
  }

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.requestFocus();

    HardwareKeyboard.instance.addHandler(_controlKey);

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          _duration = d;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        if (_isShuffle) {
          _shuffleSong();
        } else {
          _nextSong();
        }
      }
    });

    _audioPlayer.setSource(AssetSource(songs[_currentIndex].replaceFirst("assets/", "")));
  }


  @override
  void dispose(){
    HardwareKeyboard.instance.removeHandler(_controlKey);
    _focusNode.dispose();

    _audioPlayer.stop();
    _audioPlayer.dispose();
    
    super.dispose();
  }

//bale ito yung front end elements ng music player
  @override
  Widget build(BuildContext context) {

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeigt = MediaQuery.of(context).size.height;

    double coverSize = (screenWidth < screenHeigt ? 0.6 * screenWidth : 0.4 * screenHeigt);

    return Focus(
      focusNode: _focusNode,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Music Player")
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Image.asset(
                    cover[_currentIndex % cover.length],
                    width: coverSize,
                    height: coverSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.accessibility, size: 200, color: Colors.blueGrey);
                    },
                  ),
                  
                  const SizedBox(height: 40),

                  Text(
                    songs[_currentIndex].split("/").last.replaceAll(".mp3", ""), 
                    style: const TextStyle(fontSize: 25),
                  ),

                  SizedBox(
                    width: 300,
                    child: Row(
                      children: [

                        SizedBox(width: 20),

                        Text(_formatTime(_position)),
                        
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: _duration.inMilliseconds.toDouble(),
                            value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(), //para smooth milliseconds
                            onChanged: (value) async{
                              final newPosition = Duration(milliseconds: value.toInt());
                              await _audioPlayer.seek(newPosition);
                            },
                          ),
                        ),
                        Text(_formatTime(_duration)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.library_music), 
                        iconSize: 25, 
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SongListPage(
                              songs: songs, 
                              onSongSelected: (index) 
                              {Navigator.pop(context); 
                              _playSong(index);
                              },
                            ),
                          ),
                        ),
                      ), //navigation push daw

                      IconButton(
                        icon: const Icon(Icons.skip_previous), 
                        iconSize: 35,
                        onPressed: _prevSong,),

                      IconButton(
                        icon: Icon(
                          _playPause ? Icons.play_circle : Icons.pause_circle), 
                        iconSize: 55,
                        onPressed: _togglePlayPause,),

                      IconButton(
                        icon: const Icon(Icons.skip_next), 
                        iconSize: 35,
                        onPressed: _nextSong,),

                      IconButton(
                        icon: Icon(
                          _isShuffle ? Icons.shuffle_on_outlined : Icons.shuffle,
                          color: _isShuffle ? Colors.blueGrey : Colors.blueGrey
                        ), 
                        iconSize: 25,
                        onPressed: (){
                          setState(() {
                            _isShuffle = !_isShuffle;
                          });
                        },
                      ) 
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//listahan mo ng kanta boy
class SongListPage extends StatelessWidget{
  final List<String> songs;
  final Function(int) onSongSelected;

  const SongListPage({super.key, required this.songs, required this.onSongSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Song list')),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index){
          String songName = songs[index].split("/").last;
          int songNumber = index + 1;
          songName = "$songNumber. " + songName.replaceAll(".mp3", "");
          return ListTile(
            title: Text(songName),
            onTap: () => onSongSelected(index),
          );
        }
      ),
    );
  }
}