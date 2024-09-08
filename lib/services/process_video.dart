import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

// Future<String?> processVideoWithOverlay(
//     String inputPath, Map<String, Offset> textOverlays) async {
//   try {
//     final Directory tempDir = await getTemporaryDirectory();
//     final String outputPath =
//         '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

//     // Copy font file to a temporary location
//     final fontBytes = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
//     final fontFile = File('${tempDir.path}/Roboto-Regular.ttf');
//     await fontFile.writeAsBytes(fontBytes.buffer.asUint8List());

//     String filterComplex = '';
//     int index = 0;
//     textOverlays.forEach((text, offset) {
//       const boxWidth = 200;
//       const boxHeight = 40;

//       filterComplex +=
//           'drawbox=x=${offset.dx}*w:y=${offset.dy}*h:w=$boxWidth:h=$boxHeight:color=black@0.5:t=fill,';
//       filterComplex +=
//           'drawtext=text=\'$text\':fontfile=${fontFile.path}:fontcolor=white:fontsize=24:x=${offset.dx}*w+5:y=${offset.dy}*h+5';

//       if (index < textOverlays.length - 1) {
//         filterComplex += ',';
//       }
//       index++;
//     });

//     // Add rotation filter to correct the video orientation
//     filterComplex = "transpose=1,$filterComplex";

//     // Use the default H.264 encoder and AAC for audio
//     final command =
//         '-i $inputPath -vf "$filterComplex" -c:v h264 -c:a aac -strict experimental -b:a 192k -pix_fmt yuv420p $outputPath';

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
Future<String?> processVideoWithOverlay(
    String inputPath, Map<String, Offset> textOverlays) async {
  try {
    final Directory tempDir = await getTemporaryDirectory();
    final String outputPath =
        '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Copy font file to a temporary location
    final fontBytes = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final fontFile = File('${tempDir.path}/Roboto-Regular.ttf');
    await fontFile.writeAsBytes(fontBytes.buffer.asUint8List());

    String filterComplex = 'format=yuv420p,';
    int index = 0;
    textOverlays.forEach((text, offset) {
      const boxWidth = 200;
      const boxHeight = 40;

      filterComplex +=
          'drawbox=x=${offset.dx}*w:y=${offset.dy}*h:w=$boxWidth:h=$boxHeight:color=black@0.5:t=fill,';
      filterComplex +=
          'drawtext=text=\'$text\':fontfile=${fontFile.path}:fontcolor=white:fontsize=24:x=${offset.dx}*w+5:y=${offset.dy}*h+5';

      if (index < textOverlays.length - 1) {
        filterComplex += ',';
      }
      index++;
    });

    // Use more compatible encoding settings
    final command =
        '-i $inputPath -vf "$filterComplex" -c:v mpeg4 -q:v 2 -c:a aac -b:a 128k $outputPath';

    print("FFmpeg command: $command"); // Log the command for debugging

    final session = await FFmpegKit.execute(command);
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
