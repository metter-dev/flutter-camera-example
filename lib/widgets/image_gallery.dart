import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_camera_example/classes/media.dart';

class ImageGallery extends StatelessWidget {
  final List<MediaItem> mediaFiles;
  final Function(int)? onDelete;

  const ImageGallery({
    Key? key,
    required this.mediaFiles,
    this.onDelete,
  }) : super(key: key);

  Widget _buildMediaPreview(MediaItem mediaItem) {
    // Check media type
    if (mediaItem is VideoMedia) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // If there's a thumbnail, show it
          if (mediaItem.thumbnail != null)
            Image.file(
              File(mediaItem.thumbnail!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          // Show play icon overlay for videos
          const Icon(
            Icons.play_circle_outline,
            size: 32,
            color: Colors.white,
          ),
          // Optionally show duration
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(mediaItem.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (mediaItem is ImageMedia) {
      return Image.file(
        File(mediaItem.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }

    // Fallback for unknown media type
    return const Center(
      child: Icon(Icons.help_outline, color: Colors.grey),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (mediaFiles.isEmpty) {
      return const SizedBox(
        height: 100, // Give some height to empty state
        child: Center(
          child: Text('No media selected'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        final mediaItem = mediaFiles[index];

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildMediaPreview(mediaItem),
            ),
            // Type indicator (optional)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  mediaItem is VideoMedia ? Icons.videocam : Icons.image,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            if (onDelete != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onDelete!(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
