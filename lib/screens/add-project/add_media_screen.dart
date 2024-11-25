import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_example/classes/media.dart';
import 'package:flutter_camera_example/classes/video.dart';
import 'package:flutter_camera_example/screens/add-project/select_template_screen.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:flutter_camera_example/widgets/add_more_card.dart';
import 'package:flutter_camera_example/widgets/image_gallery.dart';
import 'package:flutter_camera_example/widgets/video_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;

class AddMediaScreen extends StatelessWidget {
  const AddMediaScreen({Key? key}) : super(key: key);

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
                Navigator.of(context).pop();
              },
            ),
            actions: [
              TextButton(
                child: const Text('הבא', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const SelectTemplateScreen()),
                  );
                },
              ),
            ],
          ),
          body: Consumer<AppStateModel>(
            // Add this wrapper
            builder: (context, model, child) {
              final mediaItems =
                  model.getMediaItems(); // Get media items from state

              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'הוסף סרטונים',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
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
                  ImageGallery(
                    mediaFiles: mediaItems,
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: mediaItems.length +
                          1, // Use mediaItems instead of memoryMediaList
                      itemBuilder: (context, index) {
                        if (index > 0) {
                          final mediaItem = mediaItems[index - 1];
                          // Check media type and render appropriate card
                          if (mediaItem is VideoMedia) {
                            return VideoCard(
                              videoObject: mediaItem,
                              onReshoot: () {
                                // Handle reshoot logic
                              },
                            );
                          } else {
                            return const Text('');
                          }
                        } else {
                          return AddMoreCard(
                              onTap: () {},
                              onSelect: (String type) async {
                                final ImagePicker picker = ImagePicker();

                                switch (type) {
                                  case 'upload':
                                    final List<XFile>? images =
                                        await picker.pickMultiImage();
                                    if (images != null) {
                                      for (XFile image in images) {
                                        // Create and add ImageMedia object
                                        final imageMedia = ImageMedia(
                                          path: image.path,
                                          width:
                                              0, // You'll need to get actual dimensions
                                          height: 0,
                                          createdAt: DateTime.now(),
                                        );

                                        // Add to global state
                                        GlobalState.addMediaItem(imageMedia);
                                      }
                                    }
                                    break;

                                  case 'camera':
                                    break;

                                  case 'video':
                                    break;
                                }
                              });
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
