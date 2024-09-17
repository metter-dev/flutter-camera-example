import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_example/classes/video.dart';
import 'package:flutter_camera_example/screens/add_videos_screen.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
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
  bool _isReviewing = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  String? _videoPath;
  CameraOrientation? orientation;
  int _countdownValue = 3;
  bool _isCountingDown = false;
  late VideoPlayerController _videoPlayerController;
  double _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    orientation = Provider.of<AppStateModel>(context, listen: false)
        .preferences
        .selectedOrientation;
  }

  Future<void> _initializeCamera() async {
    _controller = await initializeCamera(cameras);
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
      await videoFile.saveTo(_videoPath!);
      _recordingTimer?.cancel();

      // Initialize video player for review
      _videoPlayerController = VideoPlayerController.file(File(_videoPath!));
      await _videoPlayerController.initialize();
      await _videoPlayerController.setLooping(true);
      await _videoPlayerController.play();

      // Apply image enhancement
      await _applyImageEnhancement();

      setState(() {
        _isRecording = false;
        _isReviewing = true;
      });

      // Update position periodically
      Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (mounted && _isReviewing) {
          setState(() {
            _currentPosition =
                _videoPlayerController.value.position.inMilliseconds /
                    _videoPlayerController.value.duration.inMilliseconds;
          });
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _applyImageEnhancement() async {
    print("Applying image enhancement...");
    await Future.delayed(
        const Duration(seconds: 2)); // Simulating processing time
  }

  void _saveVideo() {
    final appState = Provider.of<AppStateModel>(context, listen: false);

    CameraOrientation? _orientation = appState.preferences.selectedOrientation;

    final videoObject = Video(
        path: _videoPath!,
        recordedAt: DateTime.now(),
        duration: Duration(seconds: _recordingDuration),
        orientation: _orientation ?? CameraOrientation.portrait);

    appState.memoryAddMedia(videoObject);

    // Add the video to AppStateModel
    Provider.of<AppStateModel>(context, listen: false).addMedia(_videoPath!);
    // Navigate back or to gallery
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AddVideosScreen()),
    );
  }

  void _reshootVideo() {
    // Reset state for new recording
    setState(() {
      _isReviewing = false;
      _recordingDuration = 0;
      _videoPath = null;
    });
    _videoPlayerController.dispose();
  }

  void _seekVideo(double position) {
    final Duration duration = _videoPlayerController.value.duration;
    final newPosition = duration * position;
    _videoPlayerController.seekTo(newPosition);
  }

  @override
  void dispose() {
    _controller.dispose();
    _recordingTimer?.cancel();
    if (_isReviewing) {
      _videoPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isReviewing) {
      return Scaffold(
        body: Stack(
          children: [
            VideoPlayer(_videoPlayerController),
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_recordingDuration ~/ 60}:${(_recordingDuration % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.0,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8.0),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 16.0),
                      ),
                      child: Slider(
                        value: _currentPosition,
                        onChanged: (newPosition) {
                          setState(() {
                            _currentPosition = newPosition;
                          });
                          _seekVideo(newPosition);
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _reshootVideo,
                        child: const Text('Reshoot'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                      ),
                      ElevatedButton(
                        onPressed: _saveVideo,
                        child: const Text('Done'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CameraPreview(_controller),
          ),
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
              offset: const Offset(
                  -52 / 2, 0), // Adjust the offset for the new button size
              child: Container(
                width: 52, // Increased button size
                height: 52, // Increased button size
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red, // Red background color
                  border: Border.all(
                    color: Colors.white, // Outer white border
                    width: 5, // Increased white border size
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors
                          .transparent, // Transparent shadow (acts as the 1px transparent border)
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _isRecording
                      ? _stopVideoRecording
                      : (_isCountingDown ? null : _startCountdown),
                  backgroundColor: Colors.red, // Ensure the button is also red

                  elevation: 0, // Remove shadow of FloatingActionButton
                ),
              ),
            ),
          ),

        ],
      ),
    );

  }
}
