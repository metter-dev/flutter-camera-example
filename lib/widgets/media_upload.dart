import 'package:flutter/material.dart';
import 'package:flutter_camera_example/classes/media.dart';
import 'package:flutter_camera_example/services/standardize_image.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class MediaUpload extends StatefulWidget {
  const MediaUpload({Key? key}) : super(key: key);

  @override
  State<MediaUpload> createState() => _MediaUploadState();
}

class _MediaUploadState extends State<MediaUpload> {
  final List<File> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      // Process each image sequentially through our standardization function
      List<File> processedFiles = [];

      for (XFile image in images) {
        File originalFile = File(image.path);
        File standardizedFile = await standardizeImage(originalFile);
        processedFiles.add(standardizedFile);

        MediaItem mediaItem = ImageMedia(
          path: standardizedFile.path,
          createdAt: DateTime.now(),
        );
        GlobalState.addMediaItem(mediaItem);
      }

      setState(() {
        _mediaFiles.addAll(processedFiles);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      // Setting preferredCameraDevice if you want to default to back camera
      preferredCameraDevice: CameraDevice.rear,
    );

    if (photo != null) {
      // Load the image file into memory
      final File imageFile = File(photo.path);
      final img.Image? originalImage =
          img.decodeImage(await imageFile.readAsBytes());

      if (originalImage != null) {
        // Calculate target dimensions to achieve 16:9 aspect ratio
        const double targetAspectRatio = 16 / 9;
        final double currentAspectRatio =
            originalImage.width / originalImage.height;

        int targetWidth = originalImage.width;
        int targetHeight = originalImage.height;

        // Determine if we need to crop width or height to achieve 16:9
        if (currentAspectRatio > targetAspectRatio) {
          // Image is too wide - crop the width
          targetWidth = (originalImage.height * targetAspectRatio).round();
        } else if (currentAspectRatio < targetAspectRatio) {
          // Image is too tall - crop the height
          targetHeight = (originalImage.width / targetAspectRatio).round();
        }

        // Calculate cropping coordinates to center the crop
        final int x = ((originalImage.width - targetWidth) / 2).round();
        final int y = ((originalImage.height - targetHeight) / 2).round();

        // Crop the image
        final img.Image croppedImage = img.copyCrop(
          originalImage,
          x: x,
          y: y,
          width: targetWidth,
          height: targetHeight,
        );

        // Create a new file path for the processed image
        final String processedPath = photo.path.replaceAll(
          '.jpg',
          '_processed.jpg',
        );

        // Save the processed image
        await File(processedPath).writeAsBytes(
          img.encodeJpg(croppedImage, quality: 90),
        );

        // Create and add the media item
        MediaItem mediaItem = ImageMedia(
          path: processedPath,
          createdAt: DateTime.now(),
        );
        GlobalState.addMediaItem(mediaItem);

        setState(() {
          _mediaFiles.add(File(processedPath));
        });

        // Clean up the original file to save storage
        await imageFile.delete();
      }
    }
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 3),
    );
    if (video != null) {
      setState(() {
        _mediaFiles.add(File(video.path));
      });
    }
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment
                  .center, // Centers the children horizontally
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(height: 12), // Vertical spacing
                Container(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10), // Padding inside the container
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Centers the text horizontally within the Column
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        textAlign:
                            TextAlign.center, // Centers the text horizontally
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign
                            .center, // Centers the subtitle text horizontally
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header and buttons card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'יש לבחור אחת מן האפשרויות כדי להעלות מדיה:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildOptionButton(
                            icon: Icons.upload_file,
                            title: 'העלה תמונות',
                            subtitle: '',
                            onTap: _pickImages,
                          ),
                          const SizedBox(width: 12),
                          Container(
                              height: 100,
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.blue,
                                    width: 1,
                                  ),
                                ),
                              )),
                          _buildOptionButton(
                            icon: Icons.camera_alt,
                            title: 'צילום תמונה',
                            subtitle: '',
                            onTap: _takePhoto,
                          ),
                          Container(
                              height: 100,
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.blue,
                                    width: 1,
                                  ),
                                ),
                              )),
                          const SizedBox(width: 12),
                          _buildOptionButton(
                            icon: Icons.videocam,
                            title: 'הקלטת סרטון',
                            subtitle: '',
                            onTap: _recordVideo,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Media preview grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    // Add this line to control the height of grid items
                    childAspectRatio: 16 / 9,
                  ),
                  itemCount: _mediaFiles.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            _mediaFiles[index],
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _mediaFiles.removeAt(index);
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
        ),
      ),
    );
  }
}
