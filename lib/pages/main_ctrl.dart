import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';

class PlayerController {
  final AudioPlayer audioPlayer;
  final List<String> songs;
  int currentIndex;
  final ValueNotifier<bool> isShuffle = ValueNotifier(false);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<double> volume;

  PlayerController({
    required this.audioPlayer,
    required this.songs,
    required this.currentIndex,
    required double initialVolume,
  }) : volume = ValueNotifier(initialVolume);

  Future<void> playSong(int index) async { 
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource(songs[index].replaceFirst("assets/", "")));
    currentIndex = index;
    isPlaying.value = true;
  }
 
  Future<void> togglePlayPause() async {
    isPlaying.value ? await audioPlayer.pause() : await audioPlayer.resume();
    isPlaying.value = !isPlaying.value;
  }
  
  Future<void> nextSong() async {
    if (isShuffle.value) { 
      shuffleSong(); 
    }else{            
      int i = (currentIndex + 1) % songs.length; 
      playSong(i); 
    }
    isPlaying.value = false;
  }
  
  Future<void> prevSong() async{
    int i = (currentIndex - 1 + songs.length) % songs.length; 
    await playSong(i);
    isPlaying.value = false;                                             
  }
  
  Future<void> shuffleSong() async{
    int i;             
    do {               
      i = Random().nextInt(songs.length); 
    } while (i == currentIndex && songs.length > 1);
    await playSong(i);     
  }

  changeVolume(double value) {
    volume.value = value.clamp(0.0, 1.0);
    audioPlayer.setVolume(volume.value);
  }
}