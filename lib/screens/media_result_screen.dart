import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera_example/classes/media.dart';
import 'package:flutter_camera_example/services/process_video.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:flutter_camera_example/widgets/image_gallery.dart';
import 'package:provider/provider.dart';

class ProcessedMedia {
  final MediaItem originalMedia;
  final String processedPath;
  final bool isProcessed;
  final String? error;

  ProcessedMedia({
    required this.originalMedia,
    required this.processedPath,
    this.isProcessed = false,
    this.error,
  });
}

class MediaResultScreen extends StatefulWidget {
  const MediaResultScreen({Key? key}) : super(key: key);

  @override
  State<MediaResultScreen> createState() => _MediaResultScreenState();
}

class _MediaResultScreenState extends State<MediaResultScreen> {
  List<String?> processedMedia = [];
  final String _logoPath =
      GlobalState.getProfileAttribute("profileImage") ?? '';
  final template = GlobalState.getProfileAttribute("template");
  final mediaItems = GlobalState.getMediaItems();
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    processMediaItems();
  }

  Future<void> processMediaItems() async {
    try {
      final result = await processMediaFile(mediaItems, template);
      setState(() {
        processedMedia = result;
      });
      print("The result: ");
      print(result);
    } catch (e) {
      print(e);
    }
  }

  Future<String> processVideo(String path) async {
    // Implement your video processing logic here
    // For example: compression, format conversion, etc.
    await Future.delayed(const Duration(seconds: 2)); // Simulate processing
    return path; // Return processed video path
  }

  Future<String> processImage(String path) async {
    // Implement your image processing logic here
    // For example: resizing, compression, filters, etc.
    await Future.delayed(const Duration(seconds: 1)); // Simulate processing
    return path; // Return processed image path
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Results'),
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: processMediaItems,
            ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            // Makes content scrollable
            scrollDirection: Axis.horizontal,
            child: Column(
              children: processedMedia
                  .map((path) => SizedBox(
                        height: 200,
                        child: Image.file(
                          File(path ?? ''),
                          fit: BoxFit
                              .cover, // This tells the image how to fit in the space
                        ),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}

class VideoPreview extends StatelessWidget {
  final String path;

  const VideoPreview({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.play_circle, color: Colors.white, size: 48),
      ),
    );
  }
}
