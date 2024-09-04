import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class MediaViewScreen extends StatefulWidget {
  final String mediaPath;

  const MediaViewScreen({Key? key, required this.mediaPath}) : super(key: key);

  @override
  _MediaViewScreenState createState() => _MediaViewScreenState();
}

class _MediaViewScreenState extends State<MediaViewScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaPath.endsWith('.mp4')) {
      _videoController = VideoPlayerController.file(File(widget.mediaPath))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.mediaPath.endsWith('.mp4');
    return Scaffold(
      appBar: AppBar(title: Text(isVideo ? 'וידאו' : 'תמונה')),
      body: Center(
        child: isVideo
            ? _videoController!.value.isInitialized
                ? RotatedBox(
                    quarterTurns: 1, // Rotate 90 degrees clockwise
                    child: AspectRatio(
                      aspectRatio: 1 / _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : const CircularProgressIndicator()
            : Image.file(File(widget.mediaPath)),
      ),
      floatingActionButton: isVideo
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                  _isPlaying = !_isPlaying;
                });
              },
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
