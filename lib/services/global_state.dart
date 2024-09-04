import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

enum CameraOrientation { landscape, portrait }

class AppState {
  CameraOrientation? selectedOrientation;
  List<String> mediaList = [];

  void setSelectedOrientation(CameraOrientation orientation) {
    selectedOrientation = orientation;
  }

  Future<void> loadMediaList() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync(recursive: true);
    mediaList = files
        .where(
            (file) => file.path.endsWith('.jpg') || file.path.endsWith('.mp4'))
        .map((file) => file.path)
        .toList();
    mediaList.sort((a, b) => b.compareTo(a)); // Sort by newest first
  }

  void addMedia(String path) {
    mediaList.insert(0, path);
  }
}

class AppStateModel extends ChangeNotifier {
  final AppState _preferences = AppState();

  AppState get preferences => _preferences;

  void setOrientation(CameraOrientation orientation) {
    _preferences.setSelectedOrientation(orientation);
    notifyListeners();
  }

  Future<void> loadMediaList() async {
    await _preferences.loadMediaList();
    notifyListeners();
  }

  void addMedia(String path) {
    _preferences.addMedia(path);
    notifyListeners();
  }
}

class GlobalState {
  static late BuildContext _context;

  static void init(BuildContext context) {
    _context = context;
  }

  static AppStateModel _getModel() {
    return Provider.of<AppStateModel>(_context, listen: false);
  }

  static void setOrientation(CameraOrientation orientation) {
    _getModel().setOrientation(orientation);
  }

  static CameraOrientation? getOrientation() {
    return _getModel().preferences.selectedOrientation;
  }

  static Future<void> loadMediaList() async {
    await _getModel().loadMediaList();
  }

  static List<String> getMediaList() {
    return Provider.of<AppStateModel>(_context, listen: false)
        ._preferences
        .mediaList;
  }

  static void addMedia(String path) {
    _getModel().addMedia(path);
  }
}
