import 'dart:io';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class TextOverlay {
  final String text;
  final Offset position;
  final Color textColor;
  final Color backgroundColor;
  final double fontSize;
  final double boxWidth;
  final double boxHeight;

  TextOverlay({
    required this.text,
    required this.position,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.fontSize = 24,
    this.boxWidth = 200,
    this.boxHeight = 40,
  });
}

Future<String?> processVideoWithComplexOverlay(
    String inputPath, List<TextOverlay> textOverlays,
    {bool isRTL = true}) async {
  try {
    final Directory tempDir = await getTemporaryDirectory();
    final String outputPath =
        '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Copy Rubik font file to a temporary location
    final fontBytes = await rootBundle.load('assets/fonts/Rubik-Regular.ttf');
    final fontFile = File('${tempDir.path}/Rubik-Regular.ttf');
    await fontFile.writeAsBytes(fontBytes.buffer.asUint8List());

    String filterComplex = '';

    for (int i = 0; i < textOverlays.length; i++) {
      final overlay = textOverlays[i];
      final escapedText = _escapeTextForFFmpeg(overlay.text);
      final bgColor = _colorToFFmpegString(overlay.backgroundColor);
      final textColor = _colorToFFmpegString(overlay.textColor);

      // Adjust x-coordinate for RTL if needed
      final xPosition = isRTL
          ? '(w-w*${overlay.position.dx})-tw/2'
          : '(w*${overlay.position.dx})-tw/2';

      // Calculate y-coordinate for both background and text
      final yPosition = 'h-h*${overlay.position.dy}-th/2';

      // Create background rectangle and text with aligned positioning
      filterComplex += 'drawtext=text=\'$escapedText\':'
          'fontfile=${fontFile.path}:'
          'fontcolor=$textColor:'
          'fontsize=${overlay.fontSize}:'
          'x=$xPosition:'
          'y=$yPosition:'
          'box=1:'
          'boxcolor=$bgColor@1:'
          'boxborderw=10';

      if (i < textOverlays.length - 1) {
        filterComplex += ',';
      }
    }

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

String _escapeTextForFFmpeg(String text) {
  return text.replaceAll("'", "'\\''");
}

String _colorToFFmpegString(Color color) {
  return '0x${color.value.toRadixString(16).padLeft(8, '0')}';
}
