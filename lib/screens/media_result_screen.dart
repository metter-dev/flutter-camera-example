import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera_example/classes/media.dart';
import 'package:flutter_camera_example/services/process_video.dart';
import 'package:flutter_camera_example/services/share_media.dart';
import 'package:flutter_camera_example/utils/global_state.dart';

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
  List<String> processedMedia = [];
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
      List<String> result = await processMediaFile(mediaItems, template);
      setState(() {
        processedMedia = result;
      });
      print("The result: ");
      print(result);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> processVideo(String path) async {
    // Implement your video processing logic here
    // For example: compression, format conversion, etc.
    await Future.delayed(const Duration(seconds: 0)); // Simulate processing
    return path; // Return processed video path
  }

  Future<String> processImage(String path) async {
    // Implement your image processing logic here
    // For example: resizing, compression, filters, etc.
    await Future.delayed(const Duration(seconds: 0));
    return path; // Return processed image path
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('תוצאות'),
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => shareMediaItems(processedMedia),
              tooltip:
                  'Share files', // Adding a tooltip for better accessibility
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: processMediaItems,
          ),
        ],
      ),
      body: Column(
        children: [
          // Main content area with media grid
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('מעבד מדיה...'),
                      ],
                    ),
                  )
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: processMediaItems,
                              child: const Text('נסה שוב'),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 16 / 9,
                        ),
                        itemCount: processedMedia.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(processedMedia[index] ?? ''),
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        processedMedia.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
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
