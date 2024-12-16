// This function handles sharing one or multiple files through the device's native sharing system
// Parameters:
//   - filePaths: A list of strings representing the paths to the files you want to share
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

Future<void> shareMediaItems(List<String> filePaths) async {
  // First, we check if we're dealing with a single file or multiple files
  // This lets us customize the sharing experience appropriately
  if (filePaths.length == 1) {
    // For a single file, we extract the filename to create a more personalized sharing message
    final fileName = path.basename(filePaths[0]);

    try {
      // Share.shareXFiles is a method from share_plus that handles the actual sharing
      // XFile is a cross-platform way to represent files
      await Share.shareXFiles(
        [XFile(filePaths[0])],
        text:
            'Check out this file: $fileName', // Custom message including the file name
      );
    } catch (e) {
      print('Error sharing file: $e');
      // You might want to handle the error here, perhaps by showing a message to the user
    }
  } else {
    // For multiple files, we need to convert all paths to XFile objects
    try {
      // Map each file path to an XFile object
      final files = filePaths.map((path) => XFile(path)).toList();

      await Share.shareXFiles(
        files,
        text:
            'Check out these ${files.length} files!', // Message indicating multiple files
      );
    } catch (e) {
      print('Error sharing files: $e');
    }
  }
}
