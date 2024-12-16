import 'dart:io';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_camera_example/classes/media.dart';
import 'package:flutter_camera_example/services/template-filter_complex/3.dart';
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
      '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}';

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
  double saturation = options?['saturation'] ?? 1.125;
  double brightness = options?['brightness'] ?? 0.2;
  double contrast = options?['contrast'] ?? 1.1;
  double sharpness = options?['sharpness'] ?? 1.5;
  double vibrance = options?['vibrance'] ?? 1.025;

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

Future<List<String>> processMediaFile(
    List<MediaItem> mediaFiles, template) async {
  try {
    print("processing for template");
    print(template);
    final logoPath = GlobalState.getProfileAttribute('profileImage');
    final Directory tempDirectory = await getTemporaryDirectory();
    final fontBytes = await rootBundle.load('assets/fonts/Rubik-Regular.ttf');
    final fontFile = File('${tempDirectory.path}/Rubik-Regular.ttf');
    await fontFile.writeAsBytes(fontBytes.buffer.asUint8List());

    // Create a temporary directory to store processed images
    final tempDir = await Directory.systemTemp.createTemp('processed_images_');
    List<String> processedPaths = [];

    if (template == 0 || template == '0') {
   
      // Process each media file
      int ind = -1;
      for (var mediaFile in mediaFiles) {
        if (mediaFile.type != MediaType.image) continue;
        ind += 1;
        final inputPath = mediaFile.path;
        final outputPath = path.join(tempDir.path, 'processed_$ind.png');

        // Calculate padding from bottom-right corner (e.g., 20 pixels)
        const padding = 35;

        // Build FFmpeg command
        // final command = '-i "$inputPath" -i "$logoPath" '
        //     '-filter_complex "'
        //     '[1:v]scale=500:500[logo];'
        //     '[0:v][logo]overlay=W-w-$padding:H-h-$padding"'
        //     ' -quality 95 "$outputPath"';
        // final command =
        //     '-i "$inputPath" -i "$logoPath" -filter_complex "[1:v]scale=trunc(iw*0.17):-1[logo];[0:v][logo]overlay=W-w-$padding:H-h-$padding" -quality 95 "$outputPath"';
        final command =
            '-i "$inputPath" -i "$logoPath" -filter_complex "[1:v]scale=200:-1[logo];[0:v][logo]overlay=W-w-$padding:H-h-$padding" -quality 95 "$outputPath"';

        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          processedPaths.add(outputPath);
        } else {
          final logs = await session.getLogs();
          for (var log in logs) {
            print(log.getMessage());
          }
        }
      }

      // If all files were processed successfully, return the paths
      if (processedPaths.isNotEmpty) {
        return processedPaths;
      }
    } else if (template == 1 || template == '1') {
      for (var mediaFile in mediaFiles) {
        String? result = await processVideoWithComplexOverlay(mediaFile.path);
        print(result);
        if (result != null) {
          processedPaths.add(result);
        }
      }

      return processedPaths;
    } else if (template == 3 || template == '3') {
      for (var mediaFile in mediaFiles) {
        if (mediaFile.type != MediaType.image) continue;

        final inputPath = mediaFile.path;
        final fileName = path.basename(inputPath);
        final outputPath = path.join(tempDir.path, 'processed_$fileName');

        File imageFile = await copyAssetToTempAndRead('assets/icons/bed.png');
        String imageOverlayPath = imageFile.path;

        // Build FFmpeg command
        String filterComplex = filter3;
        final command =
            "-i $inputPath -i $imageOverlayPath $filterComplex -map \"[out]\" $outputPath";

        // Execute FFmpeg command
        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        if (!ReturnCode.isSuccess(returnCode)) {
          final logs = await session.getLogsAsString();
          final errorLogs = await session.getLogs();
          for (var log in errorLogs) {
            print(log.getMessage());
          }
          print(
              'Command failed with return code: ${await session.getReturnCode()}');
          print('Standard logs: $logs');
          print('Complete command that was executed: $command');
        } else {
          processedPaths.add(outputPath);
        }
      }

      // If all files were processed successfully, return the paths as a comma-separated string
      if (processedPaths.isNotEmpty) {
        return processedPaths;
      }
    } else {
      for (var mediaFile in mediaFiles) {
        if (mediaFile.type != MediaType.image) continue;

        final inputPath = mediaFile.path;
        final fileName = path.basename(inputPath);
        final outputPath = path.join(tempDir.path, 'processed_$fileName');

        // Get input image dimensions
        final probeCommand =
            '-i "$inputPath" -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0';
        final probeResult = await FFprobeKit.execute(probeCommand);
        final dimensions = (await probeResult.getOutput())?.split(',');

        if (dimensions == null || dimensions.length != 2) continue;

        final inputWidth = int.parse(dimensions[0]);
        final inputHeight = int.parse(dimensions[1]);

        // Calculate logo size (e.g., 1/6 of the image width)
        final logoSize = inputWidth ~/ 6;
        // Calculate padding from bottom-right corner (e.g., 20 pixels)
        const padding = 35;

        final font =
            fontFile.path.replaceAll("'", "'\\''").replaceAll('\\', '\\\\');

        File imageFile = await copyAssetToTempAndRead('assets/icons/bed.png');
        String imageOverlayPath = imageFile.path;

        String fontSize = "h*0.04";
        // Build FFmpeg command
        final command = '''
-i $inputPath -i $imageOverlayPath -filter_complex "[0:v]drawbox=x=0:y=ih*0.85:w=iw:h=ih*0.075:color=black@0.75:t=fill[box];
[box]drawtext=fontfile=$font:fontcolor=white:text='JUST LISTED':x=40:y=h*0.79:fontsize=h*0.065[listed];
[listed]drawtext=fontfile=$font:fontcolor=white:text='3':x=w*0.05:y=h*0.87:fontsize=$fontSize[left];
[left]drawtext=fontfile=$font:fontcolor=white:text='2':x=w*0.15:y=h*0.87:fontsize=$fontSize[center];
[center]drawtext=fontfile=$font:fontcolor=white:text='1,234 מר':x=w*0.3:y=h*0.87:fontsize=$fontSize[right];
[right]drawtext=fontfile=$font:fontcolor=white:text='שח 1,000,000':x=w*0.6:y=h*0.87:fontsize=$fontSize[with_text];
[1:v]scale=-1:ih*0.055[scaled_img];
[with_text][scaled_img]overlay=x=W*0.15-w-5:y=H*0.85[out]" -map "[out]" $outputPath''';

        // Execute FFmpeg command
        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        if (!ReturnCode.isSuccess(returnCode)) {
          final logs = await session.getLogsAsString();
          final errorLogs = await session.getLogs();
          for (var log in errorLogs) {
            print(log.getMessage());
          }
          print(
              'Command failed with return code: ${await session.getReturnCode()}');
          print('Standard logs: $logs');
          print('Complete command that was executed: $command');
        } else {
          processedPaths.add(outputPath);
        }
      }

      // If all files were processed successfully, return the paths as a comma-separated string
      if (processedPaths.isNotEmpty) {
        return processedPaths;
      }
    }
  } catch (e) {
    print("processMediaFile error");
    print(e);
  }
  return [];
}

Future<String?> processLogoForAgents(String inputPath) async {
  try {
    print("testing processLogoForAgents");

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

    print("*********************************");
    dynamic state = GlobalState.getProfile();
    print(state);

    String profileImagePath = state['profileImage'];

    String temporaryOutputPath = await _getOutputPath(tempDir);
    String ffmpegCommand1 =
        '-i "$inputPath" -i "$profileImagePath" -i "$audioPath" -filter_complex "'
        '[0:v]format=rgba,geq=r=\'r(X,Y)\':a=\'1*alpha(X,Y)\'[main];'
        '[1:v]scale=iw*0.15:-1[scaled_img];'
        '[main][scaled_img]overlay=main_w-overlay_w-10:main_h-overlay_h-10[final]'
        '" -map "[final]" -map 2:a -c:v mpeg4 -q:v 1 -c:a aac -r 30 -shortest "$temporaryOutputPath"';

    final session = await FFmpegKit.execute(ffmpegCommand1);

    final returnCode = await session.getReturnCode();

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
  

Future<String?> processVideoWithComplexOverlay(
    String inputPath,
    {bool isRTL = true}) async {
  try {

    print("testing processVideoWithComplexOverlay");

    dynamic userMusicChoice = GlobalState.getProfileAttribute('music');

    if (userMusicChoice == null) {
      throw Exception("Music choice is null");
    }


    File imageFile = await copyAssetToTempAndRead('assets/bathtab.png');
    String imageOverlayPath = imageFile.path;

    File audio = await copyAssetToTempAndRead(userMusicChoice);
    String audioPath = audio.path;

    final Directory tempDir = await getTemporaryDirectory();

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

    String? price =
        GlobalState.getProfileAttribute('מחיר הנכס (לדוגמה: ₪500,000') ?? '500';
    print("*********************************");
    dynamic state = GlobalState.getProfile();
    print(price);
    print(state);

    String userPrice = state['מחיר הנכס (לדוגמה: ₪500,000)'] ?? '500';

    String temporaryOutputPath = await _getOutputPath(tempDir);

    // First, let's separate our filter complex components for clarity
    String filterComplex = ''
        // Base video/image input with black box
        '[0:v]drawbox=x=iw*$marginPercentage:'
        'y=ih*$blackBoxYPercentage-$boxHeight:'
        'w=iw*$boxWidthPercentage:'
        'h=$boxHeight:'
        'color=black@0.75:'
        't=fill[black_rect];'

        // White box overlay
        '[black_rect]drawbox=x=iw*$marginPercentage:'
        'y=ih*$whiteBoxYPercentage-$boxHeight-$boxHeight:'
        'w=iw*$boxWidthPercentage:'
        'h=$boxHeight:'
        'color=white@0.75:'
        't=fill[white_rect];'

        // Add the text with proper escaping for the font file
        '[white_rect]drawtext='
        'fontfile=${fontFile.path.replaceAll(r'\', r'\\').replaceAll("'", r"'\'")}:'
        'text=$userPrice:'
        'fontcolor=black:'
        'fontsize=$fontSize:'
        'x=w*$marginPercentage+7:'
        'y=h*$whiteBoxYPercentage-$textYOffset:'
        'box=1:'
        'boxcolor=white@0:'
        'boxborderw=5[text_rect];'

        // Scale the overlay image
        '[1:v]scale=$imageOverlayWidth:-1[scaled_img];'

        // Final overlay composition
        '[text_rect][scaled_img]overlay='
        'x=W*(1-$marginPercentage*4.5)-$imageOverlayWidth:'
        'y=H*$blackBoxYPercentage-7-h[final]';

    // Construct the full FFmpeg command
    String ffmpegCommand = '-i "$inputPath" '
        '-i "$imageOverlayPath" '
        '-filter_complex "$filterComplex" '
        '-map "[final]" '
        '-frames:v 1 '
        '-q:v 2 '
        '"$temporaryOutputPath.png"';
    // String ffmpegCommand1 =
    //     '-i "$inputPath" -i "$imageOverlayPath" -i "$audioPath" -filter_complex "'
    //     '[0:v]drawbox=x=iw*$marginPercentage:y=ih*$blackBoxYPercentage-$boxHeight:w=iw*$boxWidthPercentage:h=$boxHeight:color=black@0.75:t=fill[black_rect];'
    //     '[black_rect]drawbox=x=iw*$marginPercentage:y=ih*$whiteBoxYPercentage-$boxHeight-$boxHeight:w=iw*$boxWidthPercentage:h=$boxHeight:color=white@0.75:t=fill[white_rect];'
    //     '[white_rect]drawtext=fontfile=${fontFile.path.replaceAll("'", "'\\''").replaceAll('\\', '\\\\')}:'
    //     'text=\'שח $userPrice\':fontcolor=black:fontsize=$fontSize:x=w*$marginPercentage+7:y=h*$whiteBoxYPercentage-$textYOffset:box=1:boxcolor=white@0:boxborderw=5[text_rect];'
    //     '[text_rect]drawbox=x=iw*(1-$marginPercentage*1.5)-$redBoxSize*2:y=ih*$blackBoxYPercentage-$redBoxSize-7:w=$redBoxSize*2:h=$redBoxSize:color=red:t=fill[red_box];'
    //     '[red_box]drawtext=fontfile=${fontFile.path.replaceAll("'", "'\\''").replaceAll('\\', '\\\\')}:'
    //     'text=\'1234\':fontcolor=white:fontsize=$redBoxTextSize*1.5:x=(w-$redBoxSize*4)+$redBoxSize+14:y=h*$blackBoxYPercentage-$redBoxSize/2-7-7:box=0:boxcolor=white@0:boxborderw=0:shadowcolor=black@0.5:shadowx=1:shadowy=1[red_box_text];'
    //     '[1:v]scale=$imageOverlayWidth:-1[scaled_img];'
    //     '[red_box_text][scaled_img]overlay=x=W*(1-$marginPercentage*4.5)-$imageOverlayWidth:y=H*$blackBoxYPercentage-7-h[final]'
    //     '" -map "[final]" -map 2:a -c:v mpeg4 -q:v  1 -c:a aac -r 30 -shortest "$temporaryOutputPath"';

    final session = await FFmpegKit.execute(ffmpegCommand);

   
   
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print("Video processing completed successfully.");
      return temporaryOutputPath + '.png';
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
