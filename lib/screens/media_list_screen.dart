import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'media_view_screen.dart';

class MediaListScreen extends StatelessWidget {
  final List<String> mediaList;

  const MediaListScreen({Key? key, required this.mediaList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('הסרטונים שלך')),
      body: ListView.builder(
        itemCount: mediaList.length,
        itemBuilder: (context, index) {
          final mediaPath = mediaList[index];
          final isVideo = mediaPath.endsWith('.mp4');
          return ListTile(
            leading: Icon(isVideo ? Icons.videocam : Icons.photo),
            title: Text(path.basename(mediaPath)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MediaViewScreen(mediaPath: mediaPath),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
