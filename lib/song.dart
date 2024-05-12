import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moodmuse/widgets/player_buttons.dart';
import 'package:moodmuse/widgets/seekbar.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import '../models/song_model.dart';
import 'models/playlist_model.dart';

class SongScreen extends StatefulWidget {
  final int playlistindex;
  final int songIndex;
  const SongScreen({super.key, required this.playlistindex, required this.songIndex});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  late Song song;

  @override
  void initState() {
    super.initState();
    List<Song> playlistSongs = playlists[widget.playlistindex].songs;
    song = playlistSongs[widget.songIndex];
    audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        children: playlistSongs
            .map((song) => AudioSource.uri(Uri.parse('asset:///${song.url}')))
            .toList(),
      ),
      initialIndex: widget.songIndex,
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Stream<SeekBarData> get _seekBarDataStream =>
      rxdart.Rx.combineLatest2<Duration, Duration?, SeekBarData>(
          audioPlayer.positionStream, audioPlayer.durationStream, (
          Duration position,
          Duration? duration,
          ) {
        return SeekBarData(
          position,
          duration ?? Duration.zero,
        );
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            children: [
              const SizedBox(height: 120), // Adjust size as needed
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.3, // Set your desired height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
                  image: DecorationImage(
                    image: AssetImage(song.coverUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 70), // Adjust size as needed
              _MusicPlayer(
                song: song,
                seekBarDataStream: _seekBarDataStream,
                audioPlayer: audioPlayer,
                playlistindex: widget.playlistindex,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const _CustomNavBar(),
    );

  }
}
class _CustomNavBar extends StatefulWidget {
  const _CustomNavBar();

  @override
  State<_CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<_CustomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushNamed('/notes'); // Navigate to NotesPage
        break;
      case 1:
      // Assuming `cameraTabIndex` is the index of your camera tab
        Navigator.of(context).pushNamed('/home'); // Navigate to NotesPage
        break;
      case 2:
        Navigator.of(context).pushNamed('/favoris'); // Navigate to NotesPage
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF8F3D7E),
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.white,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.note_alt_outlined, size: 30),
          label: 'Notes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined, size: 30),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_outlined, size: 30),
          label: 'favorite',
        ),
      ],
    );
  }
}

class _MusicPlayer extends StatefulWidget {
  const _MusicPlayer({
    required this.song,
    required Stream<SeekBarData> seekBarDataStream,
    required this.audioPlayer,
    required this.playlistindex
  })  : _seekBarDataStream = seekBarDataStream;

  final int playlistindex;
  final Song song;
  final Stream<SeekBarData> _seekBarDataStream;
  final AudioPlayer audioPlayer;

  @override
  __MusicPlayerState createState() => __MusicPlayerState();
}

class __MusicPlayerState extends State<_MusicPlayer> {
  late Song currentSong;
  DateTime? lastPreviousTap;

  @override
  void initState() {
    super.initState();
    currentSong = widget.song;
  }

  void onPreviousTap() {
    final now = DateTime.now();
    if (lastPreviousTap != null && now.difference(lastPreviousTap!) < const Duration(seconds: 2)) {
      // Double tap detected, skip to the previous song
      if (widget.audioPlayer.hasPrevious) {
        widget.audioPlayer.seekToPrevious();
      }
    } else {
      // Single tap, just restart the current song
      widget.audioPlayer.seek(Duration.zero);
    }
    lastPreviousTap = now;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${currentSong.title.substring(0,currentSong.title.length > 20 ? 20 : currentSong.title.length,)}${currentSong.title.length > 20 ? '...' : ''}',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            currentSong.description,
            maxLines: 2,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 35),
          StreamBuilder<SeekBarData>(
            stream: widget._seekBarDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return SeekBar(
                position: positionData?.position ?? Duration.zero,
                duration: positionData?.duration ?? Duration.zero,
                onChangeEnd: widget.audioPlayer.seek,
              );
            },
          ),
          const SizedBox(height: 10),
          PlayerButtons(
            audioPlayer: widget.audioPlayer,
            onNext: () {
              if (widget.audioPlayer.hasNext) {
                widget.audioPlayer.seekToNext().then((_) {
                  setState(() {
                    currentSong = playlists[widget.playlistindex].
                    songs[(widget.audioPlayer.currentIndex ?? 0)];
                  });
                }).catchError((error) {
                  //print("Error switching to next song: $error");
                });
              }
            },
            onPrevious: () {
              if( widget.audioPlayer.hasPrevious){
                widget.audioPlayer.seekToPrevious().then((_) {
                  setState(() {
                    currentSong = playlists[widget.playlistindex].
                    songs[(widget.audioPlayer.currentIndex ?? 0)];
                  });
                }).catchError((error) {
                  //print("Error switching to next song: $error");
                });
              }
            },
          ),
        ],
      ),
    );
  }
}