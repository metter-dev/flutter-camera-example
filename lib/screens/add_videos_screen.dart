import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera_example/classes/video.dart';
import 'package:flutter_camera_example/screens/select_template_screen.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_camera_example/screens/camera_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
class AddVideosScreen extends StatelessWidget {
  const AddVideosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, appState, child) {
        final memoryMediaList = appState.preferences.memoryMediaList;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: TextButton(
              child: const Text('חזור', style: TextStyle(color: Colors.black)),
              onPressed: () {
                appState.clearMemoryMediaList();
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              },
            ),
            actions: [
              TextButton(
                child:
                    const Text('הבא', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const SelectTemplateScreen()),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'הוסף סרטונים',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'יש להסריט או להעלות את כל הסרטונים השייכים לפרוייקט',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: memoryMediaList.length + 1,
                  itemBuilder: (context, index) {
                    if (index > 0) {
                      return VideoCard(
                        videoObject: memoryMediaList[index - 1],
                        onReshoot: () {
                          // Handle reshoot logic
                        },
                      );
                    } else {
                      return AddMoreCard(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CameraScreen()),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



class VideoCard extends StatefulWidget {
  final Video videoObject;
  final VoidCallback onReshoot;

  const VideoCard({
    Key? key,
    required this.videoObject,
    required this.onReshoot,
  }) : super(key: key);

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoObject.path))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Uint8List?> _generateThumbnail() async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: widget.videoObject.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 25,
      );
      return thumbnail;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = _controller.value.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (!_isPlaying)
                  FutureBuilder<Uint8List?>(
                    future: _generateThumbnail(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data != null) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      } else if (snapshot.hasError) {
                        return const Center(child: Icon(Icons.error));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                else if (_isInitialized)
                  VideoPlayer(_controller),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.blue,
                        ),
                        onPressed: _isInitialized ? _togglePlayPause : null,
                        iconSize: 40,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.blue),
                        onPressed: widget.onReshoot,
                        iconSize: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text( 
            'ש${widget.videoObject.duration.inSeconds}',
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
class AddMoreCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddMoreCard({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 48),
            SizedBox(height: 8),
            Text('הוספה'),
          ],
        ),
      ),
    );
  }
}
