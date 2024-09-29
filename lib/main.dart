import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:provider/provider.dart';
import 'screens/gallery_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppStateModel(),
      child: const CameraApp(),
    ),
  );
}

class CameraApp extends StatelessWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    GlobalState.init(context);
    GlobalState.loadUserProfile();

    return MaterialApp(
      title: 'Flutter Camera Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (BuildContext context) {
              GlobalState.init(context);
              return child!;
            },
          ),
        );
      },
      home: const GalleryScreen(),
    );
  }
}
