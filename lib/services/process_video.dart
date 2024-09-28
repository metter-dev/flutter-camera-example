import 'dart:io';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageOverlay {
  final Offset position;
  final double width;
  final double height;

  ImageOverlay({
    required this.position,
    this.width = 35,
    this.height = 35,
  });
}

class BoxOverlay {
  final Offset position;
  final Color backgroundColor;
  final double width;
  final double height;
  final double opacity;

  BoxOverlay({
    required this.position,
    required this.width,
    required this.height,
    this.backgroundColor = Colors.black,
    this.opacity = 1,
  });
}

class TextOverlay {
  final String text;
  final Offset position;
  final Color textColor;
  final double fontSize;

  TextOverlay({
    required this.text,
    required this.position,
    this.textColor = Colors.white,
    this.fontSize = 24,
  });
}

Future<File> copyAssetToTempAndRead(String assetPath) async {
  if (assetPath == '') {
    return File('');
  }

  // Get the temporary directory
  final tempDir = await getTemporaryDirectory();

  // Extract the file name from the asset path
  final fileName = path.basename(assetPath);

  // Create the destination path in the temp directory
  final tempPath = path.join(tempDir.path, fileName);

  // Check if the file already exists in temp directory
  final tempFile = File(tempPath);
  if (await tempFile.exists()) {
    // If it exists, just return the file
    return tempFile;
  }

  // If the file doesn't exist, copy it from assets to temp
  final byteData = await rootBundle.load(assetPath);
  final buffer = byteData.buffer;
  await tempFile.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  // Return the file
  return tempFile;
}

Future<String> _getOutputPath(tempDir) async {
  final String outputPath =
      '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

  return outputPath;
}

Future<String> processVideoSimple(String inputPath,
    {Map<String, dynamic>? options}) async {
  final Directory tempDir = await getTemporaryDirectory();
  String outputPath = await _getOutputPath(tempDir);

  // Default values for enhanced visuals
  int width = options?['width'] ?? -1; // -1 means maintain aspect ratio
  int height = options?['height'] ?? -1;
  double hue = options?['hue'] ?? 0.0;
  double saturation = options?['saturation'] ?? 1.5; // Increased saturation
  double brightness = options?['brightness'] ?? 0.2; // Increased brightness
  double contrast = options?['contrast'] ?? 1.2; // Increased contrast
  double sharpness = options?['sharpness'] ?? 1.5; // Increased sharpness
  double vibrance = options?['vibrance'] ?? 1.3; // Increased vibrance

  // Construct the video filter string
  List<String> filters = [];
  if (width != -1 || height != -1) {
    filters.add('scale=$width:$height');
  }
  filters.add('hue=h=$hue:s=$saturation');
  filters.add('unsharp=5:5:$sharpness:5:5:0');
  filters.add('vibrance=$vibrance');

  String videoFilters = filters.join(',');

  String ffmpegCommand = '-i $inputPath ';
  if (videoFilters.isNotEmpty) {
    ffmpegCommand += '-vf "$videoFilters" ';
  }
  ffmpegCommand += '-c:v mpeg4 -preset medium -crf 23 '
      '-c:a aac -b:a 128k ' // Convert audio to AAC
      '-movflags +faststart ' // Optimize for web streaming
      '$outputPath';

  final session = await FFmpegKit.execute(ffmpegCommand);
  final returnCode = await session.getReturnCode();

  if (ReturnCode.isSuccess(returnCode)) {
    print("Video processing completed successfully.");
    return outputPath;
  } else {
    final logs = await session.getLogs();
    print("Error while processing video. FFmpeg logs:");
    for (var log in logs) {
      print(log.getMessage());
    }
    return '';
  }
}
Future<String?> processVideoWithComplexOverlay(
    String inputPath,
    {bool isRTL = true}) async {
  try {

    print("testing what the state is");

    dynamic userMusicChoice = GlobalState.getProfileAttribute('music');

    print("The music file: " + userMusicChoice == null
        ? 'no music selected'
        : userMusicChoice.toString());

    File imageFile = await copyAssetToTempAndRead('assets/bathtab.png');
    String imageOverlayPath = imageFile.path;

    File audio = await copyAssetToTempAndRead(userMusicChoice);
    String audioPath = audio.path;

    final Directory tempDir = await getTemporaryDirectory();
    final String outputPath = await _getOutputPath(tempDir);


    final fontBytes = await rootBundle.load('assets/fonts/Rubik-Regular.ttf');
    final fontFile = File('${tempDir.path}/Rubik-Regular.ttf');
    await fontFile.writeAsBytes(fontBytes.buffer.asUint8List());

double marginPercentage = 0.05;
    double boxWidthPercentage = 0.9;
    int boxHeight = 65;
    double blackBoxYPercentage = 0.95;
    double whiteBoxYPercentage = 0.95;
    int redBoxSize = 50;
    int imageOverlayWidth = 48;
    double textYOffset = boxHeight * 1.5 + 7;
    int fontSize = 28;
    int redBoxTextSize = 20;
String ffmpegCommand =
        '-i "$inputPath" -i "$imageOverlayPath" -i "$audioPath" -filter_complex "'
        '[0:v]drawbox=x=iw*$marginPercentage:y=ih*$blackBoxYPercentage-$boxHeight:w=iw*$boxWidthPercentage:h=$boxHeight:color=black@0.75:t=fill[black_rect];'
        '[black_rect]drawbox=x=iw*$marginPercentage:y=ih*$whiteBoxYPercentage-$boxHeight-$boxHeight:w=iw*$boxWidthPercentage:h=$boxHeight:color=white@0.75:t=fill[white_rect];'
        '[white_rect]drawtext=fontfile=${fontFile.path.replaceAll("'", "'\\''").replaceAll('\\', '\\\\')}:'
        'text=\'השם שלך כאן\':fontcolor=black:fontsize=$fontSize:x=w*$marginPercentage+7:y=h*$whiteBoxYPercentage-$textYOffset:box=1:boxcolor=white@0:boxborderw=5[text_rect];'
        '[text_rect]drawbox=x=iw*(1-$marginPercentage*1.5)-$redBoxSize*2:y=ih*$blackBoxYPercentage-$redBoxSize-7:w=$redBoxSize*2:h=$redBoxSize:color=red:t=fill[red_box];'
        '[red_box]drawtext=fontfile=${fontFile.path.replaceAll("'", "'\\''").replaceAll('\\', '\\\\')}:'
        'text=\'1234\':fontcolor=white:fontsize=$redBoxTextSize*1.5:x=(w-$redBoxSize*4)+$redBoxSize+14:y=h*$blackBoxYPercentage-$redBoxSize/2-7-7:box=0:boxcolor=white@0:boxborderw=0:shadowcolor=black@0.5:shadowx=1:shadowy=1[red_box_text];'
        '[1:v]scale=$imageOverlayWidth:-1[scaled_img];'
        '[red_box_text][scaled_img]overlay=x=W*(1-$marginPercentage*4.5)-$imageOverlayWidth:y=H*$blackBoxYPercentage-7-h[final]'
        '" -map "[final]" -map 2:a -c:v mpeg4 -q:v 1 -c:a aac -r 60 "$outputPath"';
        
    final session = await FFmpegKit.execute(ffmpegCommand);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print("Video processing completed successfully.");
      return outputPath;
    } else {
      final logs = await session.getLogs();
      print("Error while processing video. FFmpeg logs:");
      for (var log in logs) {
        print(log.getMessage());
      }
      return null;
    }
  } catch (e) {
    print("Exception during video processing: $e");
    return null;
  }
}
