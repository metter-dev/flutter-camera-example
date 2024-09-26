import 'package:flutter/material.dart';
import 'package:flutter_camera_example/services/process_video.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class FinalResultScreen extends StatefulWidget {
  const FinalResultScreen({Key? key}) : super(key: key);

  @override
  _FinalResultScreenState createState() => _FinalResultScreenState();
}

class _FinalResultScreenState extends State<FinalResultScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _processedVideoPath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideoPlayer();
    });
  }

  Future<void> _initializeVideoPlayer() async {
    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final String? templateIndex = GlobalState.getProfileAttribute("template");
      await _processVideoWithTemplate(int.parse(templateIndex ?? '0'));

      if (!mounted) return;

      // Always use the processed video path
      final videoPath = _processedVideoPath;

      if (videoPath == null) {
        throw Exception("Processed video path is null");
      }

      _controller = VideoPlayerController.file(File(videoPath));
      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _isProcessing = false;
      });

      _controller!.play();
      _controller!.setLooping(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to initialize video: $e';
      });
      print("Error in _initializeVideoPlayer: $e");
    }
  }

  Future<void> _processVideoWithTemplate(int templateIndex) async {
    try {
      final appState = Provider.of<AppStateModel>(context, listen: false);
      final videoPath = appState.preferences.memoryMediaList.first.path;

      List<TextOverlay> textOverlays = [];
      List<BoxOverlay> boxOverlays = [];

      double w = MediaQuery.of(context).size.width;
      double h = MediaQuery.of(context).size.height;
      double pixelRatio = MediaQuery.of(context).devicePixelRatio;

      double detailsXOffset = 0.1;

      double footerLeftMargin = (w * pixelRatio) * 0.025;

      switch (templateIndex) {
        case 0:
          boxOverlays = [
            BoxOverlay(
                position: Offset(footerLeftMargin, 100),
                width: ((pixelRatio * w) * (0.85)),
                height: 75,
                backgroundColor: Colors.black,
                opacity: 0.4),
            BoxOverlay(
                position: Offset(footerLeftMargin, 175),
                width: ((pixelRatio * w) * (0.85)).roundToDouble(),
                height: 50,
                backgroundColor: Colors.white,
                opacity: 0.65),
            BoxOverlay(
              position:
                  Offset(w * pixelRatio * (1 - detailsXOffset) - 180, 125),
              width: 75,
              height: 25,
              backgroundColor: Colors.red,
            )
          ];

          textOverlays = [
            TextOverlay(
              textColor: Colors.black,
              text: 'השם שלך מופיע כאן',
              position: Offset(detailsXOffset + 0.05, 175),
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
              text: '1234',
              position: Offset(detailsXOffset, 115),
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
        videoPath,
        textOverlays,
        boxOverlays,
        [
          ImageOverlay(
              position: Offset(w * pixelRatio * (1 - detailsXOffset) - 145,
                  (h) - (h * 3 * detailsXOffset) - 125))
        ],
      );

      if (!mounted) return;

      if (processedPath != null) {
        setState(() {
          _processedVideoPath = processedPath;
        });
      } else {
        throw Exception("Video processing failed");
      }
    } catch (e) {
      print("Error in _processVideoWithTemplate: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error processing video: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Transform.rotate(
                  angle: 360 * 3.14159265358 / 180,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          if (_isInitialized && _controller != null)
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          if (_isInitialized && _controller != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _buildVideoControls(),
            ),
          if (!_isInitialized || _isProcessing)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _isProcessing ? 'מעבד וידאו...' : 'טוען סרטון...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    if (_controller == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _controller!.value.isPlaying
                    ? _controller!.pause()
                    : _controller!.play();
              });
            },
          ),
          Expanded(
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                bufferedColor: Colors.white54,
                backgroundColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
