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
  int _currentIndex = 0; //to navigate the songs in the list
  double _volume = 1.0; //setting volume, needed for volume adjuster later on
  bool _showVolume = false; //to hide the volume setting
  bool _isPlaying = false; //listener if the song is playing
  bool _playPause = false; //toggle for play pause
  bool _isShuffle = false; //toggle for shuffle play

  Duration _duration = Duration.zero; //the whole duration of the song
  Duration _position = Duration.zero; //the current time position of the song being played

  List<String> songs = [ //song list
    "assets/music/AEAO - DJ Premier and Dynamic Duo.mp3",
    "assets/music/HER - Chase Atlantic.mp3",
    "assets/music/Swim - Chase Atlantic.mp3",
    "assets/music/Wall To Wall - Chris Brown.mp3",
    "assets/music/Often - The Weeknd.mp3",
    "assets/music/Paradise - Chase Atlantic.mp3",
    "assets/music/Beat It - Sean Kingston & Chris Brown.mp3",
    "assets/music/Slow Down - Chase Atlantic.mp3",
    "assets/music/Starboy - The Weeknd.mp3",
    "assets/music/Sugar On My Tongue - Tyler, The Creator.mp3",
    "assets/music/All I Wanna Do - Jay Park.mp3"
  ];

  List<String> cover = [ //song cover
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

  //function to play the song
  Future<void> _playSong(int index) async { 
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(songs[index].replaceFirst("assets/", "")));
    setState(() {
      _currentIndex = index;
      _isPlaying = true;
      _playPause = false;
    });
  }
  //Toggle Play Pause 
  Future<void> _togglePlayPause() async {
    _isPlaying ? await _audioPlayer.pause() : await _audioPlayer.resume();
    setState(() {
      _isPlaying = !_isPlaying;
      _playPause = !_playPause; //this will just change the play or pause button
    });
  }
  //Function for Next Song Button
  void _nextSong(){
    if (_isShuffle) { //now this will ask the button kung naka shuffle ba or nah
      _shuffleSong(); //if yes instead of pressing shuffle again automatic ng naka shuffle pag nag next
    }else{            
      int i = (_currentIndex + 1) % songs.length; //pag di nakashuffle edi plus one nalang sa index
      _playSong(i); //tawagin yung function to play the song
    }
  }
  //since may next song edi may pang relapse este previous song tayo
  void _prevSong(){
    int i = (_currentIndex - 1 + songs.length) % songs.length; //minus one lang, _currentIndex - 1 will do
    _playSong(i);                                              //pero just to be sure nilagyan ko nalang ng songs.length
  }
  //well this is shuffle song, originally you have to press it manually para shuffle
  void _shuffleSong(){ //Now this is what I did para automatic na
    int i;             
    do {               //Using do while loop, I set 
      i = Random().nextInt(songs.length); //this will pick a random number from the song list 
    } while (i == _currentIndex && songs.length > 1); //Since we're using random, this will sure na the number will not repeat.
    _playSong(i);     //If hindi nagrepeat yung song sa shuffle, it will play na yeyyy
  }

  String _formatTime(Duration d){
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  //Keyboard Listener 
  bool _controlKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space){ //Space button Listener
        _togglePlayPause();                              //It will toggle play pause
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight){ //Arrow Right Button Lister
        _nextSong();                                                 //It will trigger next song function
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft){ //Arrow Left Button Lister
        _prevSong();                                                //It will trigerr previous song function
        return true;
      }
    }
    return false;
  }

  void _changeVolume(double value) {
    setState(() {
      _volume = value;
    });
    _audioPlayer.setVolume(_volume);
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

  //Disposing passive functions like keyboard listener or the audio.
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

    var screenWidth = MediaQuery.of(context).size.width;  //just to make it responsive with the width of the screen
    var screenHeigt = MediaQuery.of(context).size.height; //the same but in height 

    double coverSize = (screenWidth < screenHeigt ? 0.6 * screenWidth : 0.4 * screenHeigt); //responsive cover size

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
                          color: _isShuffle ? Colors.blueGrey : Colors.blueGrey), 
                        iconSize: 25,
                        onPressed: (){
                          setState(() {
                            _isShuffle = !_isShuffle;
                          });
                        },
                      ), 

                      IconButton(
                        icon: Icon(_showVolume ? Icons.volume_up_outlined : Icons.volume_up,
                        color: _isShuffle ? Colors.blueGrey : Colors.blueGrey),
                        onPressed: (){
                          setState(() {
                            _showVolume = !_showVolume;
                          });
                        },
                      ),
                      
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _showVolume ? 180 : 0, // Collapse width when hidden
                        curve: Curves.easeInOut,
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _showVolume
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  min: 0.0,
                                  max: 1.0,
                                  value: _volume,
                                  onChanged: _changeVolume,
                                  activeColor: Colors.blueGrey,
                                  inactiveColor: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          secondChild: const SizedBox.shrink(),
                        ),
                      ),
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