import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/gallery_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GalleryScreen(),
    );
  }
}
