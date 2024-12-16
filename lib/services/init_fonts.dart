import 'package:flutter/services.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> initializeFont() async {
  final tempDirectory = await getTemporaryDirectory();
  final fontBytes = await rootBundle.load('assets/fonts/Rubik-Regular.ttf');
  final fontFile = File('${tempDirectory.path}/Rubik-Regular.ttf');
  await fontFile.writeAsBytes(fontBytes.buffer.asUint8List());
  final font = fontFile.path.replaceAll("'", "'\\''").replaceAll('\\', '\\\\');
  GlobalState.addProfileAttribute('font', font);
  return font;
}
