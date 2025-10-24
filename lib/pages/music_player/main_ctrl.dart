import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';

class PlayerController {
  final AudioPlayer audioPlayer;
  final List<String> songs;
  final List<String> songHistory;
  int currentIndex;
  final Duration position;
  final Duration duration;
  final ValueNotifier<bool> isShuffle = ValueNotifier(false);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> isRepeat = ValueNotifier(false);
  final ValueNotifier<double> volume;

  PlayerController({
    required this.audioPlayer,
    required this.songs,
    required this.songHistory,
    required this.position,
    required this.duration,
    required this.currentIndex,
    required double initialVolume,
  }) : volume = ValueNotifier(initialVolume);

  Future<void> playSong(int index) async { 
    if (index != currentIndex) {
      songHistory.add(songs[currentIndex]);
    }
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
    if (isShuffle.value && isRepeat.value == false) { 
      shuffleSong(); 
    }else if (isRepeat.value) {
      repeatSong();
    } else {            
      int i = (currentIndex + 1) % songs.length; 
      playSong(i); 
    }
    isPlaying.value = false;
  }
  
  Future<void> prevSong() async{
    if (songHistory.isNotEmpty) {
      playSong(songs.indexOf(songHistory.last));
      songHistory.removeLast();
    } 
    isPlaying.value = false;                                             
  }

  String prevSongPrototype = """
  Future<void> prevSong() async{
      if (position.inSeconds != 0) {
        await playSong(currentIndex); 
      } else if (songHistory.isNotEmpty) {
        playSong(songs.indexOf(songHistory.last));
        songHistory.removeLast();
      } 
      isPlaying.value = false;                                             
    }
  """;
  
  Future<void> shuffleSong() async{
    int i;             
    do {               
      i = Random().nextInt(songs.length); 
    } while (i == currentIndex && songs.length > 1);
    await playSong(i);     
  }

  Future<void> toggleRepeat() async{
    isRepeat.value = !isRepeat.value;
  }

  Future<void> repeatSong() async {
    if (isRepeat.value) {
      await playSong(currentIndex);
    }
  }

  Future<void> changeVolume(double value) async {
    volume.value = value.clamp(0.0, 1.0);
    audioPlayer.setVolume(volume.value);
  }
}