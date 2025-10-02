
String betafunctions = """

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flutter/services.dart';

//song title and song artist
    Widget songdetails = SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            songTitle,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(
            artistName,
            style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 130, 155, 168)),
          ),
        ],
      ),
    );

    //music slider
    Widget musicSlider = SizedBox(
      width: sliderWidth,
      child: Row(
        children: [
          Text(_formatTime(_position)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
              ),
              child: Slider(
                min: 0,
                max: _duration.inMilliseconds.toDouble(),
                value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
                onChanged: (value) async {
                  final newPosition = Duration(milliseconds: value.toInt());
                  await _audioPlayer.seek(newPosition);
                },
                activeColor: Colors.blueGrey,
                inactiveColor: Colors.grey,
              ),
            ),
          ),
          Text(_formatTime(_duration)),
        ],
      ),
    );

    //Main control sa music such as previous song, play, next song
    Widget playerControls = SizedBox(
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isWideScreen)
            IconButton(
              icon: const Icon(Icons.library_music), 
              iconSize: 20, 
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SongListPage(
                    songs: songs, 
                    cover: cover,
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
            iconSize: 30,
            onPressed: _prevSong,),

          IconButton(
            icon: Icon(
              _playPause ? Icons.play_circle : Icons.pause_circle), 
            iconSize: 50,
            onPressed: _togglePlayPause,),

          IconButton(
            icon: const Icon(Icons.skip_next), 
            iconSize: 30,
            onPressed: _nextSong,),

          IconButton(
            icon: Icon(
              _isShuffle ? Icons.shuffle_on_outlined : Icons.shuffle,
              color: _isShuffle ? Colors.blueGrey : Colors.blueGrey), 
            iconSize: 20,
            onPressed: (){
              setState(() {
                _isShuffle = !_isShuffle;
              });
            },
          ), 
        ],
      ), 
    );

    //volume slider to control the volume
    Widget volumeSlider = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Row(
        children: [
          if (_volume > 0.7)
            const Icon(Icons.volume_up, color: Colors.blueGrey)
          else if (_volume >= 0.3)
            const Icon(Icons.volume_down_alt, color: Colors.blueGrey)
          else 
            const Icon(Icons.volume_mute, color: Colors.blueGrey),
          
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
    );

Widget SongList = Container(
      width: 400,
      //constraints: const BoxConstraints(maxWidth: 400, maxHeight: 675),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(10, 32, 70, 1), width: 2),
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
          SizedBox(
            height: listHeight,
              child:Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                itemCount: songs.length, 
                itemBuilder: (context, index){
                  String songfile = songs[index].split("/").last.replaceAll(".mp3", "");
                  List<String> parts = songfile.split(" - ");
                  String songTitle = parts[0];
                  String artistName = parts.length > 1 ? parts[1] : "Unknown Artist";

                  bool isOn = index == _currentIndex;

                  return ListTile(
                    selected: isOn,
                    selectedTileColor: const Color.fromARGB(255, 64, 68, 75),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        cover[index % cover.length],
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
                    onTap: () => _playSong(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );

  //all widgets above are putted together in this widget making it into one
    Widget detailsAndControls = isWideScreen
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
                      image: AssetImage(cover[_currentIndex % cover.length]),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) {
                      },
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      cover[_currentIndex % cover.length],
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
""";