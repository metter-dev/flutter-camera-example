import 'package:flutter/material.dart';
import 'package:flutter_camera_example/screens/settings/settings_screen.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'media_view_screen.dart';
import 'add-project/orientation_selection_screen.dart';
import 'settings/user-profile/step_1.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  Future<Widget> _getMediaThumbnail(String mediaPath) async {
    if (mediaPath.endsWith('.jpg')) {
      return Image.file(
        File(mediaPath),
        fit: BoxFit.cover,
        width: 100,
        height: 75,
      );
    } else if (mediaPath.endsWith('.mp4')) {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: mediaPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 100,
        quality: 25,
      );
      return Image.memory(
        thumbnail!,
        fit: BoxFit.cover,
        width: 100,
        height: 75,
      );
    }
    return Container(width: 100, height: 75, color: Colors.grey);
  }

  String _getHebrewMonth(int month) {
    const months = [
      'ינו',
      'פבר',
      'מרץ',
      'אפר',
      'מאי',
      'יונ',
      'יול',
      'אוג',
      'ספט',
      'אוק',
      'נוב',
      'דצמ'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          child: Text('מֵטר', style: TextStyle(fontSize: 48)),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Consumer<AppStateModel>(
        builder: (context, appState, child) {
          final List<String> _mediaList = appState.preferences.mediaList;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'חפש פרוייקט',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // Implement search functionality if needed
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _mediaList.length,
                  itemBuilder: (context, index) {
                    final mediaPath = _mediaList[index];
                    final fileName = path.basename(mediaPath);
                    final isVideo = mediaPath.endsWith('.mp4');

                    final fileStats = File(mediaPath).statSync();
                    final dateTime = fileStats.modified;
                    final formattedDate =
                        'יום א׳, ${dateTime.day} ${_getHebrewMonth(dateTime.month)} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

                    return ListTile(
                      title:
                          Text(formattedDate, textDirection: TextDirection.rtl),
                      subtitle: Text(isVideo ? 'Landscape' : 'Portrait',
                          textDirection: TextDirection.ltr),
                      trailing: FutureBuilder<Widget>(
                        future: _getMediaThumbnail(mediaPath),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return snapshot.data ??
                                Container(
                                    width: 100, height: 75, color: Colors.grey);
                          }
                          return Container(
                              width: 100, height: 75, color: Colors.grey);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MediaViewScreen(mediaPath: mediaPath),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 0), // Adjust this value as needed
        child: SizedBox(
          width: 96,
          height: 96,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OrientationSelectionScreen()),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 40),
            backgroundColor: const Color.fromARGB(255, 76, 116, 175),
            shape: const CircleBorder(),
          ),
        ),
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings),
                  Text('הגדרות'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person),
                  Text('פרופיל'),
                ],
              ),
            ),
          ],
        ),
      ],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
