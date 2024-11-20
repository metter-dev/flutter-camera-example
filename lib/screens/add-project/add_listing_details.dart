import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera_example/screens/settings/user-profile/step_3.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:image_picker/image_picker.dart';

import 'select_music_screen.dart';

class AddListingDetailsScreen extends StatefulWidget {
  const AddListingDetailsScreen({Key? key}) : super(key: key);

  @override
  _AddListingDetailsScreenState createState() =>
      _AddListingDetailsScreenState();
}

class _AddListingDetailsScreenState extends State<AddListingDetailsScreen> {
  bool hideLogo = false;
  bool hidePhoto = false;

  String? selectedIndex = GlobalState.getProfileAttribute('template');
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    Future.microtask(() => _checkTemplateAndProfile());
  }

  void _checkTemplateAndProfile() {
    print('checking template requirement');
    print(selectedIndex);
    print(mounted);

    if (selectedIndex == 0 || selectedIndex == '0') {
      final profileImage = GlobalState.getProfileAttribute('profileImage');

      print(profileImage);

      if (profileImage == null && mounted) {
        print('showing dialog');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('נדרשת תמונת פרופיל'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'תבנית זו דורשת תמונת פרופיל. אנא העלה תמונה להמשך.'),
                      const SizedBox(height: 16),
                      if (_imageFile != null)
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.photo_camera),
                            label: const Text('צלם תמונה'),
                            onPressed: () async {
                              final XFile? image = await _picker.pickImage(
                                source: ImageSource.camera,
                                preferredCameraDevice: CameraDevice.front,
                              );
                              if (image != null) {
                                setState(() {
                                  _imageFile = File(image.path);
                                });
                              }
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: const Text('בחר מגלריה'),
                            onPressed: () async {
                              final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setState(() {
                                  _imageFile = File(image.path);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('בחר תבנית אחרת'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: const Text('שמור'),
                      onPressed: _imageFile == null
                          ? null
                          : () {
                              GlobalState.addProfileAttribute(
                                'profileImage',
                                _imageFile!.path,
                              );
                              Navigator.pop(context);
                            },
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    print('the template: ' + selectedIndex.toString());

    // If the index is 0, it is a template which requires some additional checks.
    // Use the GLobalState to retrive the profile attribute 'profileImage',
    // if it doesn't exist - prompt user to input it.

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          child: const Text('חזור'),
          onPressed: () {
            // Handle exit action
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            child: const Text('הבא', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SelectMusicScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStepIndicator(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'הוסף פרטי מודעה',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'בחר איזה מידע יוצג בסרטון שלך',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInputField('כותרת בסרטון'),
                    _buildInputField('מיקום הנכס', icon: Icons.location_on),
                    _buildInputField('מחיר הנכס (לדוגמה: ₪500,000)',
                        icon: Icons.attach_money),
                    _buildInputField('מספר חדרי שינה', icon: Icons.bed),
                    _buildInputField('מספר חדרי אמבטיה', icon: Icons.shower),
                    _buildInputField('שטח מגורים פנימי (לדוגמה: 116 מ"ר)',
                        icon: Icons.square_foot),
                    _buildInputField('גודל המגרש הכולל (לדוגמה: 218 מ"ר)',
                        icon: Icons.crop_square),
                    _buildInputField(
                        'כתוב את מספר ההפניה המלא שלך (לדוגמה: MLS# 23456, A10930224, ...)',
                        icon: Icons.tag),
                    SwitchListTile(
                      title: const Text('הסתר את הלוגו שלי'),
                      value: hideLogo,
                      onChanged: (value) {
                        setState(() {
                          hideLogo = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('הסתר את התמונה שלי'),
                      value: hidePhoto,
                      onChanged: (value) {
                        setState(() {
                          hidePhoto = value;
                        });
                      },
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressDot(false),
        _buildProgressLine(),
        _buildProgressDot(false),
        _buildProgressLine(),
        _buildProgressDot(true),
        _buildProgressLine(),
        _buildProgressDot(true),
        _buildProgressLine(),
        _buildProgressDot(true),
      ],
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.grey[300],
        border: Border.all(color: isActive ? Colors.green : Colors.grey[300]!),
      ),
      child: isActive
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : null,
    );
  }

  Widget _buildProgressLine() {
    return Container(
      width: 20,
      height: 2,
      color: Colors.grey[300],
    );
  }

  Widget _buildInputField(String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: icon != null ? Icon(icon) : null,
        ),
        onChanged: (value) async {
          print('changed with value' + value);
          await GlobalState.addProfileAttribute(label, value);
        },
      ),
    );
  }
}

Widget _buildStepIndicator() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index <= 2
                    ? Colors.green
                    : (index <= 2 ? Colors.green : Colors.grey[300]),
                border: Border.all(
                    color: index <= 2 ? Colors.green : Colors.grey[300]!),
              ),
              child: Center(
                child: index <= 1
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index <= 2 ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (index < 4)
              Container(
                width: 20,
                height: 2,
                color: index < 2 ? Colors.green : Colors.grey[300],
              ),
          ],
        );
      }),
    ),
  );
}
