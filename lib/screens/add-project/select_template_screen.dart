import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_camera_example/classes/steps.dart';
import 'package:flutter_camera_example/screens/add-project/select_music_screen.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:flutter_camera_example/widgets/StepIndicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import 'package:path/path.dart' as path;

import 'add_listing_details.dart';

int pageIndex = 3;

class SelectTemplateScreen extends StatefulWidget {
  const SelectTemplateScreen({Key? key}) : super(key: key);

  @override
  _SelectTemplateScreenState createState() => _SelectTemplateScreenState();
}

class _SelectTemplateScreenState extends State<SelectTemplateScreen> {
  int? _selectedTemplateIndex = 0;
  final List<String> _templatesTypes = [
    'הכל',
    'ללא',
    'סוכנים',
    'אירועים',
    'להשכרה'
  ];
  int? _selectedFilterIndex = 0;
  String? _processedVideoPath;
  VideoPlayerController? _videoController;
  final bool _isProcessing = false;

@override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> isInstalled() async {
    final val =
        await WhatsappShare.isInstalled(package: Package.businessWhatsapp);
    print('Whatsapp Business is installed: $val');
  }

  Future<void> share() async {
    await WhatsappShare.share(
      text: 'Whatsapp share text',
      linkUrl: 'https://flutter.dev/',
      phone: '911234567890',
    );
  }

  Future<void> shareFile(BuildContext context) async {
    final appState =
        Provider.of<AppStateModel>(context, listen: false).preferences;

    if (appState.memoryMediaList.isEmpty) {
      print("No videos available to share");
      return;
    }

    // final videoToShare = appState.memoryMediaList.first.path;
    final videoToShare = _processedVideoPath;
    final String fullPath =
        path.join(getApplicationDocumentsDirectory().toString(), videoToShare);

    print("Attempting to share file: $videoToShare");
    print("File exists: ${await File(videoToShare ?? '').exists()}");

    if (videoToShare == null || videoToShare.isEmpty) {
      print("Video file path is not available");
      return;
    }

    bool? isInstalled =
        await WhatsappShare.isInstalled(package: Package.whatsapp);
    if (isInstalled == null || !isInstalled) {
      print("WhatsApp is not installed");
      return;
    }

    try {
      File file = File(videoToShare);
      if (!await file.exists()) {
        print("File does not exist: $videoToShare");
        return;
      }

      // Generate content URI
      final uri = await WhatsappShare.shareFile(
        filePath: [videoToShare],
        package: Package.whatsapp,
        phone: '0584402014',
      );

      print("File shared successfully: $uri");
    } catch (e) {
      print("Error sharing file: $e");
    }
  }

  Future<String?> _getVideoPath(BuildContext context) async {
    final appState =
        Provider.of<AppStateModel>(context, listen: false).preferences;

    if (appState.memoryMediaList.isEmpty) {
      print("No videos available to share");
      return null;
    }

    final videoToShare = _processedVideoPath;
    if (videoToShare == null || videoToShare.isEmpty) {
      print("Video file path is not available");
      return null;
    }

    final file = File(videoToShare);
    if (!await file.exists()) {
      print("File does not exist: $videoToShare");
      return null;
    }

    return videoToShare;
  }
 
  Future<void> _initializeVideoPlayer() async {
    if (_processedVideoPath != null) {
      _videoController = VideoPlayerController.file(File(_processedVideoPath!));
      await _videoController!.initialize();
      _videoController!.play();
      _videoController!.setLooping(true);
      setState(() {});
    }
  }

  Future<void> _shareToFacebook(BuildContext context) async {
    final videoPath = await _getVideoPath(context);
    if (videoPath == null) return;

    try {
      await Share.shareXFiles([XFile(videoPath)],
          text: 'Check out this video!');
      print("File shared successfully on Facebook");
    } catch (e) {
      print("Error sharing file on Facebook: $e");
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton(
          child: const Text('חזור', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            child: const Text('הבא', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const SelectMusicScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const StepIndicator(pageIndex: 2),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'בחירת טמפלייט',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'כל טמפלייט מציג את המידע באופן שונה',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          _buildTemplateFilters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildTemplateCard(
                      index: template.index,
                      child: template.buildWidget(),
                    ),
                  ],
                );
              },
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildTemplateFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _templatesTypes.map((template) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(template),
              selected:
                  _templatesTypes.indexOf(template) == _selectedFilterIndex,
              onSelected: (selected) {
                setState(() {
                  _selectedFilterIndex =
                      selected ? _templatesTypes.indexOf(template) : 0;
                });
                print("Selected filter: ${selected ? template : 'None'}");
              },
              selectedColor: Colors.green,
              labelStyle: TextStyle(
                color: _templatesTypes.indexOf(template) == _selectedFilterIndex
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTemplateCard({required int index, required Widget child}) {
    return GestureDetector(
      onTap: () async {
        print("selected template;" + index.toString());
        setState(() {
          _selectedTemplateIndex = index;
        });

        GlobalState.addProfileAttribute(
            'template', _selectedTemplateIndex.toString());
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedTemplateIndex == index
                ? Colors.green
                : Colors.grey[300]!,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }

}
