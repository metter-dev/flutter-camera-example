import 'package:image/image.dart' as img;
import 'dart:io';

Future<File> standardizeImage(File imageFile) async {
  // Read the image file
  final bytes = await imageFile.readAsBytes();
  final image = img.decodeImage(bytes);

  // Let's set a standard width - choosing 1440 as it's a good balance
  // between quality and file size (common 2K width)
  const standardWidth = 1440;

  // Calculate height to maintain aspect ratio
  final aspectRatio = image!.height / image.width;
  final standardHeight = (standardWidth * aspectRatio).round();

  // Resize the image to our standard dimensions
  final resizedImage = img.copyResize(
    image,
    width: standardWidth,
    height: standardHeight,
    interpolation: img.Interpolation.linear,
  );

  // Encode back to JPEG format
  final processedBytes = img.encodeJpg(resizedImage, quality: 90);

  // Write back to a file
  final processedFile = File(imageFile.path)..writeAsBytesSync(processedBytes);

  return processedFile;
}
