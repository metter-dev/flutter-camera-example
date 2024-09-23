import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_camera_example/services/process_video.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import 'package:path/path.dart' as path;

class SelectTemplateScreen extends StatefulWidget {
  const SelectTemplateScreen({Key? key}) : super(key: key);

  @override
  _SelectTemplateScreenState createState() => _SelectTemplateScreenState();
}

class _SelectTemplateScreenState extends State<SelectTemplateScreen> {
  int? _selectedTemplateIndex;
  final List<String> _templates = ['הכל', 'ללא', 'סוכנים', 'אירועים', 'להשכרה'];
  String? _processedVideoPath;
  VideoPlayerController? _videoController;
  bool _isProcessing = false;

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


  Future<void> _processVideoWithTemplate(int templateIndex) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final appState = Provider.of<AppStateModel>(context, listen: false);
      final videoPath = appState.preferences.memoryMediaList.first.path;

      List<TextOverlay> textOverlays = [];
      List<BoxOverlay> boxOverlays = [];

      // List<ImageOverlay> imageOverlays = [];
      switch (templateIndex) {
        case 0:
          // imageOverlays = [
          //   ImageOverlay(
          //       assetPath: 'assets/templates/1695898721386.jpeg',
          //       position: const Offset(24, 100),
          //       width: 50,
          //       height: 50)
          // ];
          boxOverlays = [
            BoxOverlay(
                position: const Offset(24, 100),
                width: ((MediaQuery.of(context).devicePixelRatio *
                        MediaQuery.of(context).size.width) *
                    (0.99 / 2)),
                height: 75,
                backgroundColor: Colors.black,
                opacity: 0.4),
            BoxOverlay(
                position: const Offset(24, 175),
                width: ((MediaQuery.of(context).devicePixelRatio *
                            MediaQuery.of(context).size.width) *
                        (0.99 / 2))
                    .roundToDouble(),
                height: 50,
                backgroundColor: Colors.white,
                opacity: 0.65),
          ];

          textOverlays = [
            TextOverlay(
              textColor: Colors.black,
              text: 'השם שלך מופיע כאן',
              position:
                  const Offset(0.225, 175),
            ),
            TextOverlay(
              textColor: Colors.black,
              text: 'שח 1,000,000',
              position: const Offset(0.8, 175),
            ),
            TextOverlay(
              textColor: Colors.white,
              text: '(617) 123-4567',
              position: const Offset(0.8, 115),
            ),
            TextOverlay(
              textColor: Colors.white,
              text: '🛁',
              position: const Offset(0.225, 115),
            ),
          ];
      
      
      
      
          break; 
        case 1:
          textOverlays = [
            TextOverlay(
              text: 'שח 1,000,000',
              position: const Offset(0.8, 0.9),
              textColor: Colors.white,
            ),
          ];
 
          break;
        default:
          textOverlays = [];
      }

      final processedPath = await processVideoWithComplexOverlay(
          videoPath, textOverlays, boxOverlays);
      _processedVideoPath = processedPath;
      await _initializeVideoPlayer();



      if (processedPath != null) {
        setState(() {
          _processedVideoPath = processedPath;
          _isProcessing = false;
        });
      } else {
        setState(() {
          _isProcessing = false;
        });
        throw Exception("Video processing failed");
        
      }
    } catch (e) {
      print("Error in _processVideoWithTemplate: $e");
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing video: $e')),
      );
    }
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

  Future<void> _shareToTwitter(BuildContext context) async {
    final videoPath = await _getVideoPath(context);
    if (videoPath == null) return;

    try {
      await Share.shareXFiles([XFile(videoPath)],
          text: 'Check out this video!');
      print("File shared successfully on Twitter");
    } catch (e) {
      print("Error sharing file on Twitter: $e");
    }
  }

  Future<void> _shareToInstagram(BuildContext context) async {
    final videoPath = await _getVideoPath(context);
    if (videoPath == null) return;

    // Instagram doesn't support direct video sharing via URL scheme
    // We'll open the Instagram app, but the user will need to manually share the video
    const instagramUrl = 'instagram://camera';
    if (await canLaunchUrl(Uri(path: instagramUrl))) {
      await launchUrl(Uri(path: instagramUrl));
      print("Opened Instagram app. User needs to manually share the video.");
    } else {
      print("Couldn't launch Instagram app");
    }
  }


  Future<void> _shareToWhatsApp() async {
    shareFile(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton(
          child: const Text('יציאה', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            child: const Text('הבא', style: TextStyle(color: Colors.green)),
            onPressed: () {
              // Handle next screen navigation
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_videoController != null &&
                    _videoController!.value.isInitialized)
                  Column(
                    children: [

                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.62),
                        child: 
                          AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                          child: _isProcessing
                              ? const Expanded(
                                  child: Center(
                                      child: Stack(children: [
                                  Expanded(
                                      child: Center(
                                          child: CircularProgressIndicator())),
                                ])))
                              : SizedBox(
                                  height: 500,
                                  child: VideoPlayer(_videoController!)),
                        ),
                      
                      ),
                      
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.share),
                            label: const Text('שיתוף בווצאפ'),
                            onPressed: () => _shareToWhatsApp(),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.facebook),
                            label: const Text('שיתוף בפייסבוק'),
                            onPressed: () => _shareToFacebook(context),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.telegram),
                            label: const Text('שיתוף בטוויטר'),
                            onPressed: () => _shareToTwitter(context),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.lightBlue,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('שיתוף באינסטגרם'),
                            onPressed: () => _shareToInstagram(context),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      _buildTemplateCard(
                        index: 0,
                        child: _buildTemplatePreview(isFirstTemplate: true),
                      ),
                      const SizedBox(height: 16),
                      _buildTemplateCard(
                        index: 1,
                        child: _buildTemplatePreview(isFirstTemplate: false),
                      ),
                    ],
                  )
                else ...[
                  _buildTemplateCard(
                    index: 0,
                    child: _buildTemplatePreview(isFirstTemplate: true),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == 0
                      ? Colors.green
                      : (index == 1 ? Colors.green : Colors.grey[300]),
                  border: Border.all(
                      color: index <= 1 ? Colors.green : Colors.grey[300]!),
                ),
                child: Center(
                  child: index == 0
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index == 1 ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (index < 4)
                Container(
                  width: 20,
                  height: 2,
                  color: index < 1 ? Colors.green : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTemplateFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _templates.map((template) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(template),
              selected: _templates.indexOf(template) == _selectedTemplateIndex,
              onSelected: (selected) {
                setState(() {
                  _selectedTemplateIndex =
                      selected ? _templates.indexOf(template) : null;
                });
              },
              selectedColor: Colors.green,
              labelStyle: TextStyle(
                color: _templates.indexOf(template) == _selectedTemplateIndex
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
        await _processVideoWithTemplate(index);
        
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

  Widget _buildTemplatePreview({required bool isFirstTemplate}) {
    return Stack(
      children: [
        Image.asset('assets/templates/1695898721386.jpeg'),
        const Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/templates/1695898721386.jpeg'),
            radius: 20,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: isFirstTemplate
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Name Here',
                          style: TextStyle(color: Colors.white)),
                      Text('\$ 1,000,000',
                          style: TextStyle(color: Colors.white)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('להשכרה',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildInfoItem(Icons.bed, '3',
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              _buildInfoItem(Icons.bathtub, '2',
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              _buildInfoItem(Icons.square_foot, '157 מ"ר',
                                  color: Colors.white),
                            ],
                          ),
                          const Text('ש"ח1,000,000',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text,
      {Color color = Colors.black}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }
}
