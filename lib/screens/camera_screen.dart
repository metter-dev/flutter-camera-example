import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_example/services/global_state.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/recording_indicator.dart';
import '../utils/camera_utils.dart';
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
  CameraOrientation? orientation = GlobalState.getOrientation();
  int _countdownValue = 3;
  bool _isCountingDown = false;

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

  Future<void> _startCountdown() async {
    setState(() {
      _isCountingDown = true;
      _countdownValue = 3;
    });

    for (int i = 3; i > 0; i--) {
      setState(() {
        _countdownValue = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      _isCountingDown = false;
    });

    await _startVideoRecording();
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
      GlobalState.addMedia(filePath);
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
      appBar: AppBar(title: const Text('')),
      body: Stack(
        children: <Widget>[
          CameraPreview(_controller),
          if (_isRecording) RecordingIndicator(duration: _recordingDuration),
          if (_isCountingDown)
            Center(
              child: Text(
                '$_countdownValue',
                style: const TextStyle(fontSize: 100, color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 75,
            left: MediaQuery.of(context).size.width / 2,
            child: Transform.translate(
              offset: const Offset(-56 / 2, 0),
              child: FloatingActionButton(
                child: Icon(_isRecording ? Icons.stop : Icons.videocam),
                onPressed: _isRecording
                    ? _stopVideoRecording
                    : (_isCountingDown ? null : _startCountdown),
                backgroundColor: _isRecording ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
