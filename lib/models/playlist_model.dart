import 'song_model.dart';

class Playlist {
  final String title;
  final List<Song> songs;
  final String imageUrl;

  Playlist({
    required this.title,
    required this.songs,
    required this.imageUrl,
  });
}

final List<Playlist> playlists = [
  Playlist(
    title: 'Happy',
    songs: Song.songs[1],
    imageUrl:
    'assets/images/hapy.png',
  ),
    Playlist(
      title: 'Happy',
      songs: Song.songs[1],
      imageUrl:
      'assets/images/hapy.png',
    ),
    Playlist(
      title: 'Sad',
      songs: Song.songs[2],
      imageUrl:
      'assets/images/sad.png',
    ),
    Playlist(
      title: 'Surprised',
      songs: Song.songs[3],
      imageUrl:
      'assets/images/surprised.png',
    ),
  Playlist(
    title: 'Angry',
    songs: Song.songs[4],
    imageUrl:
    'assets/images/angry.png',
  ),
  Playlist(
    title: 'Favorites',
    songs: Song.songs[5],
    imageUrl:
      'assets/images/favoris.png',
  ),
];
