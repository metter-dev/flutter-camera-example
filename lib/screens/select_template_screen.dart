// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:flutter_camera_example/services/process_video.dart';
// import 'package:flutter_camera_example/services/global_state.dart';
// import 'package:whatsapp_share/whatsapp_share.dart';
// import 'package:path/path.dart' as path;

// class SelectTemplateScreen extends StatefulWidget {
//   const SelectTemplateScreen({Key? key}) : super(key: key);

//   @override
//   _SelectTemplateScreenState createState() => _SelectTemplateScreenState();
// }

// class _SelectTemplateScreenState extends State<SelectTemplateScreen> {
//   int? _selectedTemplateIndex;
//   final List<String> _templates = ['הכל', 'ללא', 'סוכנים', 'אירועים', 'להשכרה'];
//   String? _processedVideoPath;
//   VideoPlayerController? _videoController;
//   bool _isProcessing = false;
//   Future<bool>? _initializationFuture;

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     super.dispose();
//   }

//   Future<void> isInstalled() async {
//     final val =
//         await WhatsappShare.isInstalled(package: Package.businessWhatsapp);
//     print('Whatsapp Business is installed: $val');
//   }

//   Future<void> share() async {
//     await WhatsappShare.share(
//       text: 'Whatsapp share text',
//       linkUrl: 'https://flutter.dev/',
//       phone: '911234567890',
//     );
//   }

//   Future<void> shareFile(BuildContext context) async {
//     final appState =
//         Provider.of<AppStateModel>(context, listen: false).preferences;

//     if (appState.memoryMediaList.isEmpty) {
//       print("No videos available to share");
//       return;
//     }

//     final videoToShare = _processedVideoPath;
//     final String fullPath =
//         path.join(
//         getApplicationDocumentsDirectory().toString(), videoToShare ?? '');

//     print("Attempting to share file: $videoToShare");
//     print("File exists: ${await File(videoToShare ?? '').exists()}");

//     if (videoToShare == null || videoToShare.isEmpty) {
//       print("Video file path is not available");
//       return;
//     }

//     bool? isInstalled =
//         await WhatsappShare.isInstalled(package: Package.whatsapp);
//     if (isInstalled == null || !isInstalled) {
//       print("WhatsApp is not installed");
//       return;
//     }

//     try {
//       File file = File(videoToShare);
//       if (!await file.exists()) {
//         print("File does not exist: $videoToShare");
//         return;
//       }

//       // Generate content URI
//       final uri = await WhatsappShare.shareFile(
//         filePath: [videoToShare],
//         package: Package.whatsapp,
//         phone: '0584402014',
//       );

//       print("File shared successfully: $uri");
//     } catch (e) {
//       print("Error sharing file: $e");
//     }
//   }

//   Future<void> _processVideoWithTemplate(int templateIndex) async {
//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       final appState = Provider.of<AppStateModel>(context, listen: false);
//       final videoPath = appState.preferences.memoryMediaList.first.path;

//       Map<String, Offset> textOverlays;
//       switch (templateIndex) {
//         case 0:
//           textOverlays = {
//             'Your Name Here': const Offset(0.05, 0.9),
//             '\$ 1,000,000': const Offset(0.8, 0.9),
//           };
//           break;
//         case 1:
//           textOverlays = {
//             'להשכרה': const Offset(0.05, 0.85),
//             'ש"ח1,000,000': const Offset(0.8, 0.9),
//           };
//           break;
//         default:
//           textOverlays = {};
//       }

//       final processedPath =
//           await processVideoWithOverlay(videoPath, textOverlays);

//       if (processedPath != null) {
//         setState(() {
//           _processedVideoPath = processedPath;
//           _isProcessing = false;
//           _initializationFuture = _initializeVideoPlayer();
//         });
//       } else {
//         throw Exception("Video processing failed");
//       }
//     } catch (e) {
//       print("Error in _processVideoWithTemplate: $e");
//       setState(() {
//         _isProcessing = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error processing video: $e')),
//       );
//     }
//   }

//   Future<bool> _initializeVideoPlayer() async {
//     if (_processedVideoPath != null) {
//       _videoController = VideoPlayerController.file(File(_processedVideoPath!));
//       await _videoController!.initialize();
//       _videoController!.play();
//       _videoController!.setLooping(true);
//       return true;
//     }
//     return false;
//   }

//   Future<void> _shareToWhatsApp() async {
//     shareFile(context);
//   }

//   Widget _buildStepIndicator() {
//     // Implement your step indicator widget here
//     return Container();
//   }

//   Widget _buildTemplateFilters() {
//     // Implement your template filters widget here
//     return Container();
//   }

//   Widget _buildTemplateCard({required int index, required Widget child}) {
//     // Implement your template card widget here
//     return Container(child: child);
//   }

//   Widget _buildTemplatePreview({required bool isFirstTemplate}) {
//     // Implement your template preview widget here
//     return Container();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: TextButton(
//           child: const Text('יציאה', style: TextStyle(color: Colors.black)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: [
//           TextButton(
//             child: const Text('הבא', style: TextStyle(color: Colors.green)),
//             onPressed: () {
//               // Handle next screen navigation
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildStepIndicator(),
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Text(
//                   'בחירת טמפלייט',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'כל טמפלייט מציג את המידע באופן שונה',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           _buildTemplateFilters(),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 if (_isProcessing)
//                   const Center(child: CircularProgressIndicator())
//                 else if (_initializationFuture != null)
//                   FutureBuilder<bool>(
//                     future: _initializationFuture,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.done &&
//                           snapshot.data == true) {
//                         return Column(
//                           children: [
//                             AspectRatio(
//                               aspectRatio: _videoController!.value.aspectRatio,
//                               child: VideoPlayer(_videoController!),
//                             ),
//                             const SizedBox(height: 16),
//                             ElevatedButton.icon(
//                               icon: const Icon(Icons.share),
//                               label: const Text('שיתוף בווצאפ'),
//                               onPressed: _shareToWhatsApp,
//                               style: ElevatedButton.styleFrom(
//                                 foregroundColor: Colors.white,
//                                 backgroundColor: Colors.green,
//                               ),
//                             ),
//                             _buildTemplateCard(
//                               index: 0,
//                               child:
//                                   _buildTemplatePreview(isFirstTemplate: true),
//                             ),
//                             const SizedBox(height: 16),
//                             _buildTemplateCard(
//                               index: 1,
//                               child:
//                                   _buildTemplatePreview(isFirstTemplate: false),
//                             ),
//                           ],
//                         );
//                       } else {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                     },
//                   )
//                 else
//                   const Center(child: Text('No video processed yet')),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoItem(IconData icon, String text,
//       {Color color = Colors.black}) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: color),
//         const SizedBox(width: 4),
//         Text(text, style: TextStyle(color: color)),
//       ],
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_camera_example/services/process_video.dart';
import 'package:flutter_camera_example/services/global_state.dart';
import 'package:whatsapp_share/whatsapp_share.dart';

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
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _processVideoWithTemplate(int templateIndex) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final appState = Provider.of<AppStateModel>(context, listen: false);
      final videoPath = appState.preferences.memoryMediaList.first.path;

      Map<String, Offset> textOverlays;
      switch (templateIndex) {
        case 0:
          textOverlays = {
            'Your Name Here': const Offset(0.05, 0.9),
            '\$ 1,000,000': const Offset(0.8, 0.9),
          };
          break;
        case 1:
          textOverlays = {
            'להשכרה': const Offset(0.05, 0.85),
            'ש"ח1,000,000': const Offset(0.8, 0.9),
          };
          break;
        default:
          textOverlays = {};
      }

      final processedPath =
          await processVideoWithOverlay(videoPath, textOverlays);

      if (processedPath != null) {
        setState(() {
          _processedVideoPath = processedPath;
          _isProcessing = false;
        });
        await _initializeVideoPlayer();
      } else {
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
      setState(() {});
      _videoController!.play();
      _videoController!.setLooping(true);
    }
  }

  Future<void> _shareToWhatsApp() async {
    // Implement WhatsApp sharing logic here
  }

  Widget _buildTemplateCard(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTemplateIndex = index;
        });
        _processVideoWithTemplate(index);
      },
      child: Card(
        color: _selectedTemplateIndex == index ? Colors.blue.shade100 : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(
                'assets/template_${index + 1}.png',
                height: 150,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              Text(_templates[index]),
            ],
          ),
        ),
      ),
    );
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
            onPressed: _selectedTemplateIndex != null
                ? () {
                    // Navigate to next screen
                  }
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _templates.length,
                    itemBuilder: (context, index) => _buildTemplateCard(index),
                  ),
          ),
          if (_videoController != null && _videoController!.value.isInitialized)
            Column(
              children: [
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('שיתוף בווצאפ'),
                  onPressed: _shareToWhatsApp,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
