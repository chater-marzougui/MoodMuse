import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerButtons extends StatefulWidget {
  const PlayerButtons({
    Key? key,
    required this.audioPlayer,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  final AudioPlayer audioPlayer;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  _PlayerButtonsState createState() => _PlayerButtonsState();
}

class _PlayerButtonsState extends State<PlayerButtons> {
  bool isFilled = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 35,
          onPressed: () {
            setState(() {
              isFilled = !isFilled;
            });
          },
          icon: Icon(
            isFilled ? Icons.favorite : Icons.favorite_border_outlined,
            color: isFilled ? Colors.red : Colors.white,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<SequenceState?>(
                stream: widget.audioPlayer.sequenceStateStream,
                builder: (context, index) {
                  return IconButton(
                    onPressed: widget.onPrevious,
                    iconSize: 45,
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              StreamBuilder<PlayerState>(
                stream: widget.audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final processingState = snapshot.data?.processingState;
                  final playing = snapshot.data?.playing ?? false;  // Providing a default value if 'playing' is null

                  if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                    return const CircularProgressIndicator();
                  } else if (!playing) {  // 'playing' is now guaranteed to be non-nullable
                    return IconButton(
                      onPressed: widget.audioPlayer.play,
                      iconSize: 75,
                      icon: const Icon(
                        Icons.play_circle,
                        color: Colors.white,
                      ),
                    );
                  } else if (processingState != ProcessingState.completed) {

                    return IconButton(
                      onPressed: widget.audioPlayer.pause,
                      iconSize: 75,
                      icon: const Icon(
                        Icons.pause_circle,
                        color: Colors.white,
                      ),
                    );
                  } else {
                    return IconButton(
                      onPressed: () => widget.audioPlayer.seek(Duration.zero, index: widget.audioPlayer.effectiveIndices!.first),
                      iconSize: 75,
                      icon: const Icon(
                        Icons.replay_circle_filled_outlined,
                        color: Colors.white,
                      ),
                    );
                  }
                },
              ),
              StreamBuilder<SequenceState?>(
                stream: widget.audioPlayer.sequenceStateStream,
                builder: (context, index) {
                  return IconButton(
                    onPressed: widget.audioPlayer.hasNext ? widget.onNext : null,
                    iconSize: 45,
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        IconButton(
          iconSize: 35,
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.queue_music_outlined,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
