import 'package:flutter/material.dart';
import 'package:moodmuse/song.dart';

import '../models/playlist_model.dart';
import 'models/song_model.dart';

class Favoris extends StatelessWidget {
  const Favoris({super.key});

  @override
  Widget build(BuildContext context) {
    Playlist playlist = playlists[0];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My favorite songs',
          style: TextStyle(color:Colors.white),),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade100,
                  const Color(0xF5CC8ED7),
                  const Color(0xFF8F3D7E),
                ],
              ),
            ),
          ),
          Column(
            children:[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _PlaylistInformation(playlist: playlist),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Expanded(flex: 15,child: _PlaylistSongs(playlist: playlist),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaylistSongs extends StatefulWidget {
  final Playlist playlist;

  const _PlaylistSongs({Key? key, required this.playlist}) : super(key: key);

  @override
  State<_PlaylistSongs> createState() => _PlaylistSongsState();
}

class _PlaylistSongsState extends State<_PlaylistSongs> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: ScrollPhysics(), // To prevent inner list scroll
      itemCount: widget.playlist.songs.length,
      itemBuilder: (context, index) {
        return _songItem(context, widget.playlist.songs[index], index);
      },
    );
  }

  Widget _songItem(BuildContext context, Song song ,int index) {
    return InkWell(
      onTap: () {
        _playSong(index);
      },
      child: ListTile(
        leading: Text(
          '${index + 1}',
          style: Theme.of(context)
              .textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20,
          ),
        ),

        title: Text(
          song.title,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,),),
        subtitle: Text('${song.description} - 02:45',
          style: TextStyle(fontSize: 17, color: Colors.black),),
        trailing: const Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
      ),
    );
  }

  void _playSong(int index) {
    // Implement song playing logic here
    // Use a package like 'audioplayers' to play the song
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SongScreen(playlistindex: 5,songIndex: 0,)));
  }
}


class _PlayOrShuffleSwitch extends StatefulWidget {
  const _PlayOrShuffleSwitch({
    Key? key,
  }) : super(key: key);

  @override
  State<_PlayOrShuffleSwitch> createState() => _PlayOrShuffleSwitchState();
}

class _PlayOrShuffleSwitchState extends State<_PlayOrShuffleSwitch> {
  bool isPlay = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        setState(() {
          isPlay = !isPlay;
        });
      },
      child: Container(
        height: 50,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isPlay ? 0 : width * 0.45,
              child: Container(
                height: 50,
                width: width * 0.45,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade400,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Play',
                          style: TextStyle(
                            color: isPlay ? Colors.white : Colors.deepPurple,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.play_circle,
                        color: isPlay ? Colors.white : Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Shuffle',
                          style: TextStyle(
                            color: isPlay ? Colors.deepPurple : Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.shuffle,
                        color: isPlay ? Colors.deepPurple : Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistInformation extends StatelessWidget {
  const _PlaylistInformation({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height:95,),
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Image.asset(
            'assets/images/fav.png',
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.height * 0.3,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 30),

      ],
    );
  }
}
