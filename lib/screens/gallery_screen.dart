import 'package:flutter/material.dart';
import 'package:flutter_camera_example/services/global_state.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'media_view_screen.dart';
import 'orientation_selection_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

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

  Widget _buildNavItem(IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 9),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

  
    final List<String> _mediaList = GlobalState.getMediaList();



    return Scaffold(
      appBar: AppBar(
        title: const Text('מֵטר', style: TextStyle(fontSize: 42)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'חפש פרוייקט',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
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
                  title: Text(formattedDate, textDirection: TextDirection.rtl),
                  subtitle: Text(isVideo ? 'Landscape' : 'Portrait',
                      textDirection: TextDirection.ltr),
                  trailing: FutureBuilder<Widget>(
                    future: _getMediaThumbnail(mediaPath),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const OrientationSelectionScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 76, 116, 175),
        shape: const CircleBorder(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'הגדרות',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'פרופיל',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            print('Navigate to Settings screen');
          } else if (index == 1) {
            print('Navigate to Profile screen');
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
