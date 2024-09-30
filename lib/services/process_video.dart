import 'dart:io';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<bool> verifyInputs(
    String inputVideoPath, String appendImagePath, int videoDuration) async {
  bool isValid = true;

  // Check if input video file exists
  if (!await File(inputVideoPath).exists()) {
    print('Error: Input video file does not exist: $inputVideoPath');
    isValid = false;
  }

  // Check if append image file exists
  if (!await File(appendImagePath).exists()) {
    print('Error: Append image file does not exist: $appendImagePath');
    isValid = false;
  }

  // Verify video duration
  if (videoDuration <= 0) {
    print('Error: Invalid video duration: $videoDuration');
    isValid = false;
  }

  // Use FFprobe to get video information
  if (await File(inputVideoPath).exists()) {
    final result = await Process.run('ffprobe', [
      '-v',
      'error',
      '-select_streams',
      'v:0',
      '-count_packets',
      '-show_entries',
      'stream=width,height,duration,nb_read_packets',
      '-of',
      'csv=p=0',
      inputVideoPath
    ]);

    if (result.exitCode == 0) {
      final info = result.stdout.toString().split(',');
      if (info.length >= 4) {
        print('Video Width: ${info[0]}');
        print('Video Height: ${info[1]}');
        print('Video Duration: ${info[2]} seconds');
        print('Number of Packets: ${info[3]}');
      } else {
        print('Error: Unable to get complete video information');
        isValid = false;
      }
    } else {
      print('Error running FFprobe: ${result.stderr}');
      isValid = false;
    }
  }

  return isValid;
}


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
  double saturation = options?['saturation'] ?? 1.125; // Increased saturation
  double brightness = options?['brightness'] ?? 0.2; // Increased brightness
  double contrast = options?['contrast'] ?? 1.1; // Increased contrast
  double sharpness = options?['sharpness'] ?? 1.5; // Increased sharpness
  double vibrance = options?['vibrance'] ?? 1.025; // Increased vibrance

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

    File outro = await copyAssetToTempAndRead('assets/outro.png');
    String outroPath = outro.path;

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

    
    String temporaryOutputPath = await _getOutputPath(tempDir);

    String ffmpegCommand1 =
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
        '" -map "[final]" -map 2:a -c:v mpeg4 -q:v 5 -c:a aac -r 30 -shortest "$temporaryOutputPath"';

    final session = await FFmpegKit.execute(ffmpegCommand1);

    int videoWidth = 1280;
    int videoHeight = 720;
    int videoDuration = 10;

    String ffmpegCommand2 =
        '-i $temporaryOutputPath -loop 1 -framerate 25 -t 3 -i $outputPath -t 3 -f lavfi -i aevalsrc=0 -i bar.png -filter_complex \'[1:0]scale=640:480[curtain];[0:0][0:1][curtain][2:0] concat=n=2:v=1:a=1[out];[out][3:0]overlay=W-w-25:H-h-25\' -max_muxing_queue_size 1000 output.mp4 -loglevel \'trace\'';
   
    // String ffmpegCommand2 =
    //     '-i "$temporaryOutputPath" -i "$outroPath" -filter_complex "'
    //     '[0:v][1:v]concat=n=2:v=1:a=0[outv];'
    //     '[0:a][1:a]concat=n=2:v=0:a=1[outa]'
    //     '" -map "[outv]" -map "[outa]" -c:v mpeg4 -q:v 5 -c:a aac -r 30 "$outputPath"';


    final session2 = await FFmpegKit.execute(ffmpegCommand2);
   
   
   
    final returnCode = await session2.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print("Video processing completed successfully.");
      return temporaryOutputPath;
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
