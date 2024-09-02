import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MaterialApp(home: CameraApp()));
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  bool _isRecording = false;
  List<String> _mediaList = [];
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  String? _videoPath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadMediaList();
  }

  Future<void> _initializeCamera() async {
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _controller.initialize();
    await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    if (mounted) setState(() {});
  }

  Future<void> _loadMediaList() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync(recursive: true);
    setState(() {
      _mediaList = files
          .where((file) =>
              file.path.endsWith('.jpg') || file.path.endsWith('.mp4'))
          .map((file) => file.path)
          .toList();
      _mediaList.sort((a, b) => b.compareTo(a)); // Sort by newest first
    });
  }

  Future<void> _takePicture() async {
    final XFile image = await _controller.takePicture();
    setState(() {
      _mediaList.insert(0, image.path);
    });
  }

  Future<void> _startVideoRecording() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
        _videoPath = filePath;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      return;
    }

    try {
      XFile videoFile = await _controller.stopVideoRecording();
      final String filePath = _videoPath!;
      await videoFile.saveTo(filePath);
      setState(() {
        _isRecording = false;
        _mediaList.insert(0, filePath);
      });
      _recordingTimer?.cancel();
      _videoPath = null;
    } catch (e) {
      print(e);
    }
  }

  void _viewMediaList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaListScreen(mediaList: _mediaList),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Camera App')),
      body: Stack(
        children: <Widget>[
          CameraPreview(_controller),
          if (_isRecording)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      '${_recordingDuration ~/ 60}:${(_recordingDuration % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    child: const Icon(Icons.camera_alt),
                    onPressed: _isRecording ? null : _takePicture,
                    backgroundColor: _isRecording ? Colors.grey : null,
                  ),
                  FloatingActionButton(
                    child: Icon(_isRecording ? Icons.stop : Icons.videocam),
                    onPressed: _isRecording
                        ? _stopVideoRecording
                        : _startVideoRecording,
                    backgroundColor: _isRecording ? Colors.red : null,
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.photo_library),
                    onPressed: _isRecording ? null : _viewMediaList,
                    backgroundColor: _isRecording ? Colors.grey : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MediaListScreen extends StatelessWidget {
  final List<String> mediaList;

  const MediaListScreen({Key? key, required this.mediaList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media List')),
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

class MediaViewScreen extends StatefulWidget {
  final String mediaPath;

  const MediaViewScreen({Key? key, required this.mediaPath}) : super(key: key);

  @override
  _MediaViewScreenState createState() => _MediaViewScreenState();
}

class _MediaViewScreenState extends State<MediaViewScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaPath.endsWith('.mp4')) {
      _videoController = VideoPlayerController.file(File(widget.mediaPath))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.mediaPath.endsWith('.mp4');
    return Scaffold(
      appBar: AppBar(title: Text(isVideo ? 'Video' : 'Photo')),
      body: Center(
        child: isVideo
            ? _videoController!.value.isInitialized
                ? RotatedBox(
                    quarterTurns: 1, // Rotate 90 degrees clockwise
                    child: AspectRatio(
                      aspectRatio: 1 / _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : const CircularProgressIndicator()
            : Image.file(File(widget.mediaPath)),
      ),
      floatingActionButton: isVideo
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                  _isPlaying = !_isPlaying;
                });
              },
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
