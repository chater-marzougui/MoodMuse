import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/song_model.dart'; // Ensure this import points to your actual Song model

class SongPage extends StatelessWidget {
  final Song song;

  const SongPage({Key? key, required this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade800,
      ),
      backgroundColor: Colors.deepPurple.shade200, // Set the background color for the entire page
      body: Center(
        child: SongCard(song: song),
      ),
    );
  }
}

class SongCard extends StatelessWidget {
  const SongCard({
    Key? key,
    required this.song,
  }) : super(key: key);

  final Song song;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/song', arguments: song);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // Smaller image size
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              image: DecorationImage(
                image: AssetImage(song.coverUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            color: Colors.deepPurple.shade200,
            child: Column(
              children: [
                Icon(
                  Icons.play_circle,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  song.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  song.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
