import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_example/classes/video.dart';
import 'package:flutter_camera_example/screens/add-project/add_videos_screen.dart';
import 'package:flutter_camera_example/services/process_video.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import '../../widgets/recording_indicator.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isReviewing = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  String _videoPath = '';
  CameraOrientation? orientation;
  int _countdownValue = 3;
  bool _isCountingDown = false;
  VideoPlayerController? _videoPlayerController;
  double _currentPosition = 0.0;
  bool _isCameraReady = false;
  bool _isLoading = false;
  bool isCountdownTimer =
      GlobalState.getProfileAttribute('isCountdownTimer') == 'on';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _recordingTimer?.cancel();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
      fps: 60,
    );

    controller.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _controller = controller;
          _isCameraReady = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }

    orientation = Provider.of<AppStateModel>(context, listen: false)
        .preferences
        .selectedOrientation;
  }

  Future<void> _startCountdown() async {

    if (isCountdownTimer) {
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
    }

    await _startVideoRecording();
  }

  Future<void> _startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await _controller!.startVideoRecording();
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
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      XFile videoFile = await _controller!.stopVideoRecording();
      await videoFile.saveTo(_videoPath);
      _recordingTimer?.cancel();

      await _applyImageEnhancement();

      _videoPlayerController = VideoPlayerController.file(File(_videoPath));
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setLooping(true);
      await _videoPlayerController!.play();

      setState(() {
        _isRecording = false;
        _isReviewing = true;
        _isLoading = false;
      });

      Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (mounted && _isReviewing) {
          setState(() {
            _currentPosition =
                _videoPlayerController!.value.position.inMilliseconds /
                    _videoPlayerController!.value.duration.inMilliseconds;
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

    String result = await processVideoSimple(_videoPath);


    _videoPath = result;
  }

  void _saveVideo() {
    final appState = Provider.of<AppStateModel>(context, listen: false);

    CameraOrientation? _orientation = appState.preferences.selectedOrientation;

    final videoObject = Video(
        path: _videoPath,
        recordedAt: DateTime.now(),
        duration: Duration(seconds: _recordingDuration),
        orientation: _orientation ?? CameraOrientation.portrait);

    appState.memoryAddMedia(videoObject);
    appState.addMedia(_videoPath);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddVideosScreen()),
    );
  }

  void _reshootVideo() {
    setState(() {
      _isReviewing = false;
      _recordingDuration = 0;
      _videoPath = '';
    });
    _videoPlayerController?.dispose();
  }

  void _seekVideo(double position) {
    final Duration duration = _videoPlayerController!.value.duration;
    final newPosition = duration * position;
    _videoPlayerController!.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isReviewing) {
      return _buildReviewScreen();
    }

    return _buildCameraScreen();
  }

  Widget _buildCameraScreen() {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: <Widget>[
              _buildCameraPreview(),
              if (_isRecording)
                RecordingIndicator(duration: _recordingDuration),
              if (_isCountingDown)
                IgnorePointer(
                  ignoring: true,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Text(
                        '$_countdownValue',
                        style:
                            const TextStyle(fontSize: 100, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              _buildCaptureButton(),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraPreview() {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    final scale = 1 / (_controller!.value.aspectRatio * deviceRatio);

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 75,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.transparent,
                spreadRadius: 1,
              ),
            ],
          ),
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: _isRecording
                ? _stopVideoRecording
                : ((_isCountingDown) ? null : _startCountdown),
            backgroundColor: Colors.red,
            elevation: 0,
            child: Icon(
              _isRecording ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            ),
            Positioned(
              top: 20,
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
                        child: const Text('מחדש',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                      ),
                      ElevatedButton(
                        onPressed: _saveVideo,
                        child: const Text('המשך',
                            style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}
