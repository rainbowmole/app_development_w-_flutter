import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'song_list.dart';
import 'lyrics.dart';

class MusicPlayerUIControls extends StatefulWidget {
  final bool isWideScreen;
  final ValueNotifier<bool> isShuffle;
  final ValueNotifier<bool> isPlaying;
  final ValueChanged<bool> toggleShuff;
  final String songTitle;
  final String artistName;
  final double sliderWidth;
  final double volume;
  final Duration position;
  final Duration duration;
  final int currentIndex;
  final List<String> songs;
  final List<String> cover;
  final AudioPlayer audioPlayer;
  final Function(int) playSong;
  final VoidCallback prevSong;
  final VoidCallback nextSong;
  final VoidCallback togglePlayPause;
  final VoidCallback shuffleSong;
  final ValueChanged<double> changeVolume; 

  const MusicPlayerUIControls({
    super.key,
    required this.isWideScreen,
    required this.isShuffle,
    required this.isPlaying,
    required this.toggleShuff,
    required this.songTitle,
    required this.artistName,
    required this.sliderWidth,
    required this.volume,
    required this.position,
    required this.duration,
    required this.currentIndex,
    required this.songs,
    required this.cover,
    required this.audioPlayer,
    required this.playSong,
    required this.prevSong,
    required this.nextSong,
    required this.togglePlayPause,
    required this.shuffleSong,
    required this.changeVolume,
  });

  @override
  State<MusicPlayerUIControls> createState() => _MusicPlayerUIControlsState();
}

class _MusicPlayerUIControlsState extends State<MusicPlayerUIControls> {

  String _formatTime(Duration d){
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context){
    Widget songdetails = SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.songTitle,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.artistName,
            style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 130, 155, 168)),
          ),
        ],
      ),
    );

    Widget musicSlider = SizedBox(
      width: widget.sliderWidth,
      child: Row(
        children: [
          Text(_formatTime(widget.position)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
              ),
              child: Slider(
                min: 0,
                max: widget.duration.inMilliseconds.toDouble(),
                value: widget.position.inMilliseconds.clamp(0, widget.duration.inMilliseconds).toDouble(),
                onChanged: (value) async {
                  final newPosition = Duration(milliseconds: value.toInt());
                  await widget.audioPlayer.seek(newPosition);
                },
                activeColor: Colors.blueGrey,
                inactiveColor: Colors.grey,
              ),
            ),
          ),
          Text(_formatTime(widget.duration)),
        ],
      ),
    );

    Widget playerControls = SizedBox(
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!widget.isWideScreen)
            IconButton(
              icon: const Icon(Icons.library_music), 
              iconSize: 20, 
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SongListPage(
                    songs: widget.songs, 
                    cover: widget.cover,
                    onSongSelected: (index) 
                    {Navigator.pop(context); 
                    widget.playSong(index);
                    },
                  ),
                ),
              ),
            ), //navigation push daw

          IconButton(
            icon: const Icon(Icons.skip_previous), 
            iconSize: 30,
            onPressed: widget.prevSong,),
          
          ValueListenableBuilder<bool>(
            valueListenable: widget.isPlaying,
            builder: (context, isPlaying, _) {
              return IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle : Icons.play_circle,
                ),
                iconSize: 50,
                onPressed: widget.togglePlayPause,
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.skip_next), 
            iconSize: 30,
            onPressed: widget.nextSong,),

          ValueListenableBuilder<bool>(
            valueListenable: widget.isShuffle,
            builder: (context, isShuffle, _) {
              return IconButton(
                icon: Icon(
                  isShuffle ? Icons.shuffle_on_outlined : Icons.shuffle,
                  color: Colors.blueGrey,
                ),
                iconSize: 20,
                onPressed: () {
                  widget.isShuffle.value = !isShuffle;
                },
              );
            },
          ), 
        ],
      ), 
    );

    Widget volumeSlider = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Row(
        children: [
          if (widget.volume > 0.7)
            const Icon(Icons.volume_up, color: Colors.blueGrey)
          else if (widget.volume >= 0.3)
            const Icon(Icons.volume_down_alt, color: Colors.blueGrey)
          else 
            const Icon(Icons.volume_mute, color: Colors.blueGrey),
          
          Expanded(
            child: Slider(
              min: 0.0,
              max: 1.0,
              value: widget.volume,
              onChanged: widget.changeVolume,
              activeColor: Colors.blueGrey,
              inactiveColor: Colors.grey,
            ),
          ),
        ],
      ),  
    );

    String lyricPrototype = """
    Widget lyricWidget = SizedBox(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ShowLyrics(
            songTitle: widget.songTitle, 
            artistName: widget.artistName)
        ],
      ),
    );
    """;
    
    return widget.isWideScreen
      ? Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(widget.cover[widget.currentIndex % widget.cover.length]),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) {
                      },
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.cover[widget.currentIndex % widget.cover.length],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.music_note, size: 40, color: Colors.blueGrey);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                songdetails
              ],
            ),

            Transform.translate(
              offset: const Offset(-75, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(0, 18),
                    child: playerControls,
                  ),
                  const SizedBox(height: 2),
                  musicSlider
                ],
              ),
            ),
            volumeSlider
          ],
        )
      : Column(
          children: [
            songdetails,
            const SizedBox(height: 20),
            musicSlider,
            const SizedBox(height: 10),
            Transform.translate(
              offset: Offset(0, -19),
              child: playerControls,
            )
          ],
        );
      
  } // inside of widget build para di ka malito
}
