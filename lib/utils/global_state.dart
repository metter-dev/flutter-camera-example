import 'package:flutter/material.dart';
import 'package:flutter_camera_example/classes/video.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

enum CameraOrientation { landscape, portrait }


class AppState {
  CameraOrientation? selectedOrientation;
  List<String> mediaList = [];
  List<Video> memoryMediaList = [];
  Map<String, String> userProfile = {};

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

  void memoryAddMedia(Video videoObject) {
    memoryMediaList.insert(0, videoObject);
  }

  void clearMemoryMediaList() {
    memoryMediaList.clear();
  }

  Future<void> addProfileAttribute(String key, String value) async {
    userProfile[key] = value;
    await saveUserProfile();
  }

  String? getProfileAttribute(String key) {
    return userProfile[key];
  }

  Future<void> saveUserProfile() async {
    print("saved to state ");
    final prefs = await SharedPreferences.getInstance();
    String userProfileJson = jsonEncode(userProfile); // Convert map to JSON
    await prefs.setString('userProfile', userProfileJson); // Save JSON string
  }

  Future<void> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? userProfileJson = prefs.getString('userProfile');

    print("the user profile is now" + userProfileJson.toString());
    if (userProfileJson != null) {
      userProfile =
          Map<String, String>.from(jsonDecode(userProfileJson)); // Restore map
    }
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

  void memoryAddMedia(Video videoObject) {
    _preferences.memoryAddMedia(videoObject);
    notifyListeners();
  }

  Future<void> saveUserProfile() async {
    await _preferences.saveUserProfile();
  }

  Future<void> loadUserProfile() async {
    await _preferences.loadUserProfile();
    notifyListeners();
  }

  void clearMemoryMediaList() {
    _preferences.clearMemoryMediaList();
    notifyListeners();
  }

  Future<void> addProfileAttribute(String key, String value) async {
    await _preferences.addProfileAttribute(key, value);
    notifyListeners(); 
  }

  String? getProfileAttribute(String key) {
    return _preferences.getProfileAttribute(key);
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
        .preferences
        .mediaList;
  }

  

  static Future<void> saveUserProfile() async {
    await _getModel().saveUserProfile();
  }

  static Future<void> loadUserProfile() async {
    await _getModel().loadUserProfile();
  }

  static void addMedia(String path) {
    _getModel().addMedia(path);
  }

  static void memoryAddMedia(Video videoObject) {
    _getModel().memoryAddMedia(videoObject);
  }

  static void clearMemoryMediaList() {
    _getModel().clearMemoryMediaList();
  }

  static Future<void> addProfileAttribute(String key, String value) async {
    await _getModel().addProfileAttribute(key, value);
  } 

  static String? getProfileAttribute(String key) {
    return _getModel().getProfileAttribute(key);
  }
}
