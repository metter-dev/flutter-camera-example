import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<CameraController> initializeCamera(
    List<CameraDescription> cameras) async {
  final camera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.back,
    orElse: () => cameras.first,
  );
  final controller = CameraController(
    camera,
    ResolutionPreset.high,
    enableAudio: false,
  );
  await controller.initialize();
  await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
  return controller;
}

Future<List<String>> loadMediaList() async {
  final directory = await getApplicationDocumentsDirectory();
  final files = directory.listSync(recursive: true);
  final mediaList = files
      .where((file) => file.path.endsWith('.jpg') || file.path.endsWith('.mp4'))
      .map((file) => file.path)
      .toList();
  mediaList.sort((a, b) => b.compareTo(a)); // Sort by newest first
  return mediaList;
}
