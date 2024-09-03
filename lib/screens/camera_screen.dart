import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/recording_indicator.dart';
import '../utils/camera_utils.dart';
import 'media_list_screen.dart';
import '../main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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
    _controller = await initializeCamera(cameras);
    if (mounted) setState(() {});
  }

  Future<void> _loadMediaList() async {
    _mediaList = await loadMediaList();
    if (mounted) setState(() {});
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Camera App')),
      body: Stack(
        children: <Widget>[
          CameraPreview(_controller),
          if (_isRecording) RecordingIndicator(duration: _recordingDuration),
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
