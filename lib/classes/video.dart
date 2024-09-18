import 'package:flutter_camera_example/utils/global_state.dart';

class Video {
  final String path;
  final DateTime recordedAt;
  final Duration duration;
  final CameraOrientation orientation;

  Video(
      {required this.path,
      required this.recordedAt,
      required this.duration,
      this.orientation = CameraOrientation.portrait});
}
