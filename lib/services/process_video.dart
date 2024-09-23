import 'dart:io';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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

Future<File> copyAssetToTempAndRead(String assetPath) async {
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

Future<String?> processVideoWithComplexOverlay(String inputPath,
    List<TextOverlay> textOverlays, List<BoxOverlay> boxOverlays,
    {bool isRTL = true}) async {
  try {
    File imageFile =
        await copyAssetToTempAndRead('assets/templates/1695898721386.jpeg');
    String imagePath = imageFile.path;

    final Directory tempDir = await getTemporaryDirectory();
    final String outputPath =
        '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final fontBytes = await rootBundle.load('assets/fonts/Rubik-Regular.ttf');
    final fontFile = File('${tempDir.path}/Rubik-Regular.ttf');
    await fontFile.writeAsBytes(fontBytes.buffer.asUint8List());

    final probeResult = await FFprobeKit.execute(
        '-v error -select_streams v:0 -count_packets -show_entries stream=width,height,r_frame_rate,nb_read_packets -of csv=p=0 $inputPath');
    final probeOutput = await probeResult.getOutput();
    final videoInfo = probeOutput?.trim().split(',');

    if (videoInfo == null || videoInfo.length < 4) {
      throw Exception('Failed to get video information');
    }

    final width = int.parse(videoInfo[0]);
    final height = int.parse(videoInfo[1]);
    final frameRateParts = videoInfo[2].split('/');
    final frameRate =
        double.parse(frameRateParts[0]) / double.parse(frameRateParts[1]);

    final targetFrameRate = frameRate > 30 ? 30 : frameRate;

    List<String> filters = [];
    filters.add('[0:v]scale=$width:$height,setsar=1[video]');
    filters.add('[1:v]scale=25:25[icon]');
    filters.add(
        '[video][icon]overlay=10:10[img_overlay]'); // Position the icon at (10,10)

    String lastOutput = 'img_overlay';

    for (int i = 0; i < boxOverlays.length; i++) {
      BoxOverlay box = boxOverlays[i];
      double xPosition = box.position.dx;
      double yPosition = box.position.dy;
      double boxWidth = box.width;
      double boxHeight = box.height;
      String backgroundColor = _colorToFFmpegString(box.backgroundColor);

      String currentOutput = 'box$i';
      filters.add('[$lastOutput]drawbox=x=$xPosition:y=ih-h-$yPosition:'
          'w=$boxWidth:h=$boxHeight:'
          'color=$backgroundColor@${box.opacity}:t=fill[$currentOutput]');
      lastOutput = currentOutput;
    }

    for (int i = 0; i < textOverlays.length; i++) {
      final overlay = textOverlays[i];
      final escapedText = _escapeTextForFFmpeg(overlay.text);
      final textColor = _colorToFFmpegString(overlay.textColor);

      const boxWidth = 700;
      const xOffset = 0;

      final xPosition = isRTL
          ? '(w-w*${overlay.position.dx})-$boxWidth/2+$xOffset'
          : '(w*${overlay.position.dx})-$boxWidth/2+$xOffset';
      final yPosition = 'h-${overlay.fontSize * 1.25}-${overlay.position.dy}';

      String currentOutput = 'text$i';
      filters.add('[$lastOutput]drawtext=text=\'$escapedText\':'
          'fontfile=${fontFile.path}:'
          'fontsize=${overlay.fontSize}:'
          'fontcolor=$textColor:'
          'x=$xPosition+($boxWidth-tw)/2:'
          'y=$yPosition[$currentOutput]');
      lastOutput = currentOutput;
    }

    String filterComplex = filters.join(';');

    final audioProbeResult = await FFprobeKit.execute(
        '-i $inputPath -show_streams -select_streams a -loglevel error');
    final hasAudio = (await audioProbeResult.getOutput())?.isNotEmpty ?? false;

    String audioMapping = hasAudio ? '-map 0:a' : '';

    final command = '-i $inputPath -i $imagePath '
        '-filter_complex "$filterComplex" '
        '-map "[$lastOutput]" '
        '$audioMapping '
        '-c:v mpeg4 '
        '${hasAudio ? '-c:a aac -b:a 128k' : ''} '
        '-r $targetFrameRate '
        '-pix_fmt yuv420p '
        '-max_muxing_queue_size 1024 '
        '$outputPath';

    print("FFmpeg command: $command");

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
  // Extract individual color components
  int red = color.red;
  int green = color.green;
  int blue = color.blue;
  int alpha = color.alpha;

  // Format the color string in the order expected by FFmpeg
  return '0x${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}'
      '${alpha.toRadixString(16).padLeft(2, '0')}';
}
