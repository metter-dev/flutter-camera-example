// import 'dart:io';
// import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_full/return_code.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';

// class BoxOverlay {
//   final Offset position;
//   final Color backgroundColor;
//   final double width;
//   final double height;
//   final double opacity;

//   BoxOverlay({
//     required this.position,
//     required this.width,
//     required this.height,
//     this.backgroundColor = Colors.black,
//     this.opacity = 1,
//   });
// }
// class TextOverlay {
//   final String text;
//   final Offset position;
//   final Color textColor;
//   final double fontSize;

//   TextOverlay({
//     required this.text,
//     required this.position,
//     this.textColor = Colors.white,
//     this.fontSize = 28,
//   });
// }

// Future<String?> processVideoWithComplexOverlay(
//     String inputPath,
//     List<TextOverlay> textOverlays, List<BoxOverlay> boxOverlays,
//     {bool isRTL = true}) async {
//   try {
//     final Directory tempDir = await getTemporaryDirectory();
//     final String outputPath =
//         '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';
//     // Copy Rubik font file to a temporary location
//     final fontBytes = await rootBundle.load('assets/fonts/Rubik-Regular.ttf');
//     final fontFile = File('${tempDir.path}/Rubik-Regular.ttf');
//     await fontFile.writeAsBytes(fontBytes.buffer.asUint8List());

//     String filterComplex = '';

//     for (int i = 0; i < boxOverlays.length; i++) {
//       BoxOverlay box = boxOverlays[i];
//       double xPosition = box.position.dx;
//       double yPosition = box.position.dy;
//       double width = box.width;
//       double height = box.height;
//       String backgroundColor = _colorToFFmpegString(box.backgroundColor);

//       // Create background rectangle
//       filterComplex += 'drawbox=x=$xPosition:y=ih-h-$yPosition:'
//           'w=$width:h=$height:'
//           'color=$backgroundColor@${box.opacity}:t=fill,';
//     }
//     for (int i = 0; i < textOverlays.length; i++) {
//       final overlay = textOverlays[i];
//       final escapedText = _escapeTextForFFmpeg(overlay.text);
//       final textColor = _colorToFFmpegString(overlay.textColor);

//       const boxWidth = 700; // Width in pixels
//       const boxHeight = 100; // Height in pixels
//       const xOffset = 0; // Horizontal offset in pixels

// // Calculate positions
//       final xPosition = isRTL
//           ? '(w-w*${overlay.position.dx})-$boxWidth/2+$xOffset'
//           : '(w*${overlay.position.dx})-$boxWidth/2+$xOffset';
//       final yPosition = 'h-${overlay.fontSize * 1.25}-${overlay.position.dy}';

// // Add text overlay
//       filterComplex += 'drawtext=text=\'$escapedText\':'
//           'fontfile=${fontFile.path}:'
//           'fontsize=${overlay.fontSize}:'
//           'fontcolor=$textColor:'
//           'x=$xPosition+($boxWidth-tw)/2:' // Center text horizontally in box
//           'y=$yPosition:'; // Center text vertically in box

//       if (i < textOverlays.length - 1) {
//         filterComplex += ',';
//       }
//     }

//     final command =
//         '-i $inputPath -vf "$filterComplex" -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k $outputPath';

//     print("FFmpeg command: $command"); // Log the command for debugging

//     final session = await FFmpegKit.execute(command);
//     final returnCode = await session.getReturnCode();

//     if (ReturnCode.isSuccess(returnCode)) {
//       print("Video processing completed successfully.");
//       return outputPath;
//     } else {
//       final logs = await session.getLogs();
//       print("Error while processing video. FFmpeg logs:");
//       for (var log in logs) {
//         print(log.getMessage());
//       }
//       return null;
//     }
//   } catch (e) {
//     print("Exception during video processing: $e");
//     return null;
//   }
// }

// String _escapeTextForFFmpeg(String text) {
//   return text.replaceAll("'", "'\\''");
// }

// String _colorToFFmpegString(Color color) {
//   // Extract individual color components
//   int red = color.red;
//   int green = color.green;
//   int blue = color.blue;
//   int alpha = color.alpha;

//   // Format the color string in the order expected by FFmpeg
//   return '0x${red.toRadixString(16).padLeft(2, '0')}'
//       '${green.toRadixString(16).padLeft(2, '0')}'
//       '${blue.toRadixString(16).padLeft(2, '0')}'
//       '${alpha.toRadixString(16).padLeft(2, '0')}';
// }
import 'dart:io';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
    this.fontSize = 28,
  });
}

class ImageOverlay {
  final String assetPath;
  final Offset position;

  ImageOverlay({
    required this.assetPath,
    required this.position,
  });
}

Future<String?> processVideoWithComplexOverlay(
    String inputPath,
    List<TextOverlay> textOverlays,
    List<BoxOverlay> boxOverlays,
    List<ImageOverlay> imageOverlays,
    {bool isRTL = true}) async {
  try {
    final Directory tempDir = await getTemporaryDirectory();
    final String outputPath =
        '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final fontFile = await _prepareFontFile(tempDir);

    // Prepare image overlays
    final preparedImageOverlays = await Future.wait(
        imageOverlays.map((overlay) => _prepareImageOverlay(overlay, tempDir)));

    String filterComplex = '';

    // Add input for each image overlay
    for (int i = 0; i < preparedImageOverlays.length; i++) {
      filterComplex += '[$i:v]';
    }

    // Start with the main video input
    filterComplex += '[0:v]';

    filterComplex += _createBoxOverlays(boxOverlays);
    filterComplex += _createTextOverlays(textOverlays, fontFile, isRTL);
    filterComplex += _createImageOverlays(preparedImageOverlays);

    // Name the final output
    filterComplex += '[out]';

    // Construct the full FFmpeg command
    String command = '-i $inputPath';

    // Add input for each image
    for (var imageFile in preparedImageOverlays) {
      command += ' -i ${imageFile.path}';
    }

    command += ' -filter_complex "$filterComplex"'
        ' -map "[out]" -map 0:a'
        ' -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k $outputPath';

    print("FFmpeg command: $command");

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print("Video processing completed successfully.");
      return outputPath;
    } else {
      _logFFmpegError(session);
      return null;
    }
  } catch (e) {
    print("Exception during video processing: $e");
    return null;
  }
}

Future<File> _prepareFontFile(Directory tempDir) async {
  final fontBytes = await rootBundle.load('assets/fonts/Rubik-Regular.ttf');
  final fontFile = File('${tempDir.path}/Rubik-Regular.ttf');
  await fontFile.writeAsBytes(fontBytes.buffer.asUint8List());
  return fontFile;
}

Future<File> _prepareImageOverlay(
    ImageOverlay overlay, Directory tempDir) async {
  final bytes = await rootBundle.load(overlay.assetPath);
  final file = File('${tempDir.path}/${overlay.assetPath.split('/').last}');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  return file;
}

String _createBoxOverlays(List<BoxOverlay> boxOverlays) {
  return boxOverlays.map((box) {
    final backgroundColor = _colorToFFmpegString(box.backgroundColor);
    return 'drawbox=x=${box.position.dx}:y=ih-h-${box.position.dy}:'
        'w=${box.width}:h=${box.height}:'
        'color=$backgroundColor@${box.opacity}:t=fill,';
  }).join();
}

String _createTextOverlays(
    List<TextOverlay> textOverlays, File fontFile, bool isRTL) {
  return textOverlays.map((overlay) {
    final escapedText = _escapeTextForFFmpeg(overlay.text);
    final textColor = _colorToFFmpegString(overlay.textColor);
    const boxWidth = 700;
    const xOffset = 0;

    final xPosition = isRTL
        ? '(w-w*${overlay.position.dx})-$boxWidth/2+$xOffset'
        : '(w*${overlay.position.dx})-$boxWidth/2+$xOffset';
    final yPosition = 'h-${overlay.fontSize * 1.25}-${overlay.position.dy}';

    return 'drawtext=text=\'$escapedText\':'
        'fontfile=${fontFile.path}:'
        'fontsize=${overlay.fontSize}:'
        'fontcolor=$textColor:'
        'x=$xPosition+($boxWidth-tw)/2:'
        'y=$yPosition,';
  }).join();
}

String _createImageOverlays(List<File> preparedImageOverlays) {
  String filterComplex = '';
  for (int i = 0; i < preparedImageOverlays.length; i++) {
    filterComplex += 'overlay=${i + 1}:x=0:y=0';
    if (i < preparedImageOverlays.length - 1) {
      filterComplex += '[temp$i];[temp$i]';
    }
  }
  return filterComplex;
}

String _escapeTextForFFmpeg(String text) {
  return text.replaceAll("'", "'\\''");
}

String _colorToFFmpegString(Color color) {
  int red = color.red;
  int green = color.green;
  int blue = color.blue;
  int alpha = color.alpha;

  return '0x${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}'
      '${alpha.toRadixString(16).padLeft(2, '0')}';
}

void _logFFmpegError(FFmpegSession session) async {
  final logs = await session.getLogs();
  print("Error while processing video. FFmpeg logs:");
  for (var log in logs) {
    print(log.getMessage());
  }
}
