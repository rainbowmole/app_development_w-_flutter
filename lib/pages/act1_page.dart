import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'ui_ctrl.dart';
import 'song_list.dart';
import 'main_ctrl.dart';



class ActivityPage1 extends StatefulWidget {
  const ActivityPage1({super.key});

  @override
  _YourMusicPlayer createState() => _YourMusicPlayer();
}

class _YourMusicPlayer extends State<ActivityPage1>{
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0; 
  double _volume = 1.0;  
  bool _isPlaying = false; 
  bool _isShuffle = false; 

  Duration _duration = Duration.zero; 
  Duration _position = Duration.zero; 

  List<String> songs = [ 
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
    "assets/music/All I Wanna Do - Jay Park.mp3",
    "assets/music/THAT'S MY BABY - PLAYERTWO.mp3"
  ];

  List<String> cover = [ 
    "assets/cover/AEAO.jpg",
    "assets/cover/HER.jpg",
    "assets/cover/SWIM.jpg",
    "assets/cover/Wall to Wall.jpg",
    "assets/cover/Often.jpg",
    "assets/cover/Paradise.jpg",
    "assets/cover/Beat it.jpg",
    "assets/cover/Paradise.jpg",
    "assets/cover/Starboy.jpg",
    "assets/cover/SOMT.jpg",
    "assets/cover/AIWD.jpg",
    "assets/cover/TMB.jpg"
  ];

  late FocusNode _focusNode;
  late PlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = PlayerController(
      audioPlayer: _audioPlayer, 
      songs: songs, 
      currentIndex: _currentIndex, 
      isShuffle: _isShuffle, 
      initialVolume: _volume);

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
          controller.shuffleSong();
        } else {
          controller.nextSong();
        }
      }
    });

    _audioPlayer.setSource(AssetSource(songs[_currentIndex].replaceFirst("assets/", "")));
  }

  //Keyboard Listener 
  bool _controlKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space){ 
        controller.togglePlayPause();                              
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight){ 
        controller.nextSong();                                                 
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft){ 
        controller.prevSong();                                                
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp){
        setState(() {
          _volume = (_volume + 0.1).clamp(0.0, 1.0);
        });
        _audioPlayer.setVolume(_volume);
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown){
        setState(() {
          _volume = (_volume - 0.1).clamp(0.0, 1.0);
        });
        _audioPlayer.setVolume(_volume);
        return true;
      }
    }
    return false;
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

    //pang himay sa song title and artist
    String songfile = songs[controller.currentIndex].split("/").last.replaceAll(".mp3", "");
    List<String> parts = songfile.split(" - "); //[0 = song title, 1 = artist]
    String songTitle = parts[0];
    String artistName = parts.length > 1 ? parts[1] : "Unknown Artist";

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;   

    bool isWideScreen = screenWidth > 969;
    bool isAnchored = isWideScreen;

    double coverSize = (screenWidth > 1000 ? screenHeight * 0.60 : 
                       (screenWidth > 940 ? screenHeight * 0.55 : 
                       (screenWidth > 830 ? screenHeight * 0.50 :
                       (screenWidth > 700 ? screenHeight * 0.45  : 
                       screenHeight * 0.40  ))));
    
    double listHeight = screenHeight > 960 ? 655 : 
                        screenHeight > 940 ? screenHeight * 0.50 :
                        screenHeight > 900 ? screenHeight * 0.65 : 
                        screenHeight * 0.01;
    listHeight = listHeight.clamp(250, 675);
    double sliderWidth = isWideScreen ? screenWidth * 0.35  : 300;

    return Focus( 
      focusNode: _focusNode,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Music Player")
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 635),
          child: LayoutBuilder(
            builder: (context, constraints) { 
              return SafeArea(
                child:  isAnchored ? 
                Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10),
                          SongListWidget(
                            songs: songs, 
                            cover: cover, 
                            listHeight: listHeight, 
                            currentIndex: controller.currentIndex, 
                            onSongSelected: controller.playSong),
                          Expanded(
                            child: Center(
                              child: Image.asset(
                                cover[controller.currentIndex % cover.length],
                                width: coverSize,
                                height: coverSize,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.accessibility, size: 200, color: Colors.blueGrey);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 33),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 10, 32, 70),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.all(10.0),
                      constraints: const BoxConstraints(maxWidth: 1900, maxHeight: 150),
                      child: MusicPlayerUIControls(
                        isWideScreen: isWideScreen, 
                        isShuffle: _isShuffle, 
                        toggleShuff: (value) {
                            setState(() {
                              _isShuffle = value;
                            });
                        },
                        isPlaying: controller.isPlaying, 
                        songTitle: songTitle, 
                        artistName: artistName, 
                        sliderWidth: sliderWidth, 
                        volume: _volume, 
                        position: _position, 
                        duration: _duration, 
                        currentIndex: controller.currentIndex, 
                        songs: songs, 
                        cover: cover, 
                        audioPlayer: _audioPlayer, 
                        playSong: controller.playSong, 
                        prevSong: controller.prevSong, 
                        nextSong: controller.nextSong, 
                        togglePlayPause: controller.togglePlayPause, 
                        shuffleSong: controller.shuffleSong,
                        changeVolume: controller.changeVolume),
                    ),
                    
                    const SizedBox(height: 10),
                  ],
                )
                : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        Image.asset(
                          cover[controller.currentIndex % cover.length],
                          width: coverSize,
                          height: coverSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.accessibility, size: 200, color: Colors.blueGrey);
                          },
                        ),
                        const SizedBox(height: 40),
                        MusicPlayerUIControls(
                          isWideScreen: isWideScreen, 
                          isShuffle: _isShuffle, 
                          toggleShuff: (value) {
                            setState(() {
                              _isShuffle = value;
                            });
                          },
                          isPlaying: controller.isPlaying, 
                          songTitle: songTitle, 
                          artistName: artistName, 
                          sliderWidth: sliderWidth, 
                          volume: _volume, 
                          position: _position, 
                          duration: _duration, 
                          currentIndex: controller.currentIndex, 
                          songs: songs, 
                          cover: cover, 
                          audioPlayer: _audioPlayer, 
                          playSong: controller.playSong, 
                          prevSong: controller.prevSong, 
                          nextSong: controller.nextSong, 
                          togglePlayPause: controller.togglePlayPause, 
                          shuffleSong: controller.shuffleSong,
                          changeVolume: controller.changeVolume
                        ),
                        const SizedBox(height: 10)
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}