import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_camera_example/classes/video.dart';
import 'package:provider/provider.dart';
import 'package:flutter_camera_example/services/global_state.dart';
import 'package:flutter_camera_example/screens/camera_screen.dart';

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
              child: const Text('Exit', style: TextStyle(color: Colors.black)),
              onPressed: () {
                // Clear the memory media list and go back
                appState.clearMemoryMediaList();
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              },
            ),
            actions: [
              TextButton(
                child:
                    const Text('Next', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  // Handle next screen navigation
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
                      'Add your shots',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Record or import all the videos/pictures you want to use for this project',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  children: [
                    ...memoryMediaList
                        .map((videoObject) => VideoCard(
                              videoObject: videoObject,
                              onPlay: () {
                                // Handle play logic
                              },
                              onReshoot: () {
                                // Handle reshoot logic
                              },
                            ))
                        .toList(),
                    AddMoreCard(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const CameraScreen()),
                        );
                        // The new video will be added to memoryMediaList in CameraScreen
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VideoCard extends StatelessWidget {
  final Video videoObject;
  final VoidCallback onPlay;
  final VoidCallback onReshoot;

  const VideoCard({
    Key? key,
    required this.videoObject,
    required this.onPlay,
    required this.onReshoot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(videoObject.path),
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: onPlay,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: onReshoot,
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Text(
              '${videoObject.duration.inSeconds}s',
              style: const TextStyle(
                  color: Colors.white, backgroundColor: Colors.black54),
            ),
          ),
        ],
      ),
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
            Text('Add more'),
          ],
        ),
      ),
    );
  }
}
