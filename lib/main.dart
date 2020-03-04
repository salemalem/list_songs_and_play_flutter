import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';


Future<void> printArtists(audioQuery) async {
  List<ArtistInfo> artists = await audioQuery.getArtists(); // returns all artists available

  artists.forEach( (artist){
    debugPrint(artist.toString()); /// prints all artist property values
  });
}

Future<void> printSongs(audioQuery) async {
  /// getting all songs available on device storage
  List<SongInfo> songs = await audioQuery.getSongs();

  songs.forEach( (song){
    debugPrint(song.filePath);
  } );
}

// source: https://stackoverflow.com/questions/57004220/how-to-get-all-mp3-files-from-internal-as-well-as-external-storage-in-flutter
Future<List<List<String>>> getSongs() async {
  var dir = await getExternalStorageDirectory();
//  String mp3Path = dir.path + "/";
  List<FileSystemEntity> _files;
//  List<FileSystemEntity> _songs = [];
  List<String> songsPaths = [];
  List<String> songsNames = [];
  List<String> songsArtists = [];
  _files = dir.listSync(recursive: true, followLinks: false);
  for(FileSystemEntity entity in _files) {
    String path = entity.path;
    if(path.endsWith('.mp3')) {
      songsPaths.add(path);
      var songName = path
          .split("/")
          .last;
      songName = songName.split(".mp3")[0];
      var songSplittedNames = songName.split("-");
      songsNames.add(songSplittedNames[0].trimRight().trimLeft());
      songsArtists.add(songSplittedNames[1].trimRight().trimLeft());
    }
  }
  return [songsPaths, songsNames, songsArtists];
}

// global variables
List<String> localSongsPaths = [];
List<String> localSongsNames = [''];
List<String> localSongsArtists = [''];
int _currentIndex = 0;
int _maxIndexes = localSongsNames.length - 1;
var playPauseState = Icon(Icons.pause);
bool isPlaying = true;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  getSongs().then((val) {
    localSongsPaths = val[0];
    localSongsNames = val[1];
    localSongsArtists = val[2];
  });

  runApp(
    MaterialApp(
      home: MusicListView(),
    )
  );
}

class MusicListView extends StatefulWidget {
  @override
  _MusicListViewState createState() => _MusicListViewState();
}

class _MusicListViewState extends State<MusicListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "WidgetX Музыка Ойнатқышы"
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      localSongsNames[index],
                  ),
                  subtitle: Text(
                    localSongsArtists[index],
                  ),

                );
              },
              itemCount: localSongsNames.length,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent,
              border: Border.all(
                color: Colors.blueAccent,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35.0),
                  topRight: Radius.circular(35.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                  Icons.music_note
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(localSongsNames[_currentIndex]),
                    Text(
                      localSongsArtists[_currentIndex],
                      style: TextStyle(
                        color: Colors.black54
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: () {
                        // play previous song
                        if(_currentIndex > 0) {
                          setState(() {
                            _currentIndex--;
                          });
                        } else {
                          setState(() {
                            _currentIndex = _maxIndexes;
                          });
                        }
                        debugPrint(_currentIndex.toString());
                      },
                    ),
                    IconButton(
                      icon: playPauseState,
                      onPressed: () {
                        setState(() {
                          if(isPlaying) {
                            playPauseState = Icon(Icons.play_arrow);
                          } else {
                            playPauseState = Icon(Icons.pause);
                          }
                        });
                        isPlaying = !isPlaying;
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: () {
                        // play next song
                        if(_currentIndex < _maxIndexes) {
                          setState(() {
                            _currentIndex++;
                          });
                        } else {
                          setState(() {
                            _currentIndex = 0;
                          });
                        }
                        debugPrint(_currentIndex.toString());
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}