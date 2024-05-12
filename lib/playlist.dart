import 'package:flutter/material.dart';
import 'package:moodmuse/song.dart';

import '../models/playlist_model.dart';
import 'models/song_model.dart';

class PlaylistScreen extends StatefulWidget {
  final int playlistindex;
  const PlaylistScreen({super.key , required this.playlistindex});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Playlist',style: TextStyle(color: Colors.white,)),
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
                    _PlaylistInformation(playlist: playlists[widget.playlistindex]),
                    const SizedBox(height: 30),
                    const _PlayOrShuffleSwitch(),
                  ],
                ),
              ),
              Expanded(flex: 15,child: _PlaylistSongs(index: widget.playlistindex,),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaylistSongs extends StatefulWidget {
  final int index; // This now represents the playlist index

  const _PlaylistSongs({required this.index});
  @override
  State<_PlaylistSongs> createState() => _PlaylistSongsState();

}

class _PlaylistSongsState extends State<_PlaylistSongs> {
  void _showPopupMenu(BuildContext context , int songIndex) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete Song'),
        ),
        const PopupMenuItem<String>(
          value: 'play',
          child: Text('Play'),
        ),
        const PopupMenuItem<String>(
          value: 'favorites',
          child: Text('Add to Favorites'),
        ),
      ],
    );
    if (selected != null) {
      // Handle the action based on the selected value
      switch (selected) {
        case 'delete':
        // Implement delete song functionality
        print("delete");
          break;
        case 'play':
        // Implement play song functionality
          Navigator.push(context, MaterialPageRoute(builder: (context) => SongScreen(playlistindex: widget.index, songIndex: songIndex)));
          break;
        case 'favorites':
          print("Favorites");
        // Implement add to favorites functionality
          break;
      }
    }
    // Handle the selected action
  }



  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: ScrollPhysics(), // To prevent inner list scroll
      itemCount: playlists[widget.index].songs.length,
      itemBuilder: (context, index) {
        return _songItem(context, playlists[widget.index].songs[index], index);
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
              style: TextStyle(fontSize: 17, color: Colors.black,),),
        trailing: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onPressed: () => _showPopupMenu(context ,index),
            );
          },
        ),
      ),
              );
  }

  void _playSong(int songIndex) {
    // Implement song playing logic here
    // Use a package like 'audioplayers' to play the song
    Navigator.push(context, MaterialPageRoute(builder: (context) => SongScreen(playlistindex: widget.index, songIndex: songIndex)));
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
                  color: Color(0xFF8F3D7E),
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
        SizedBox(height:70,),
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Image.asset(
            playlist.imageUrl,
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.height * 0.3,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          playlist.title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
