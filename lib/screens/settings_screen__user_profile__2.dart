import 'package:flutter/material.dart';
import 'package:flutter_camera_example/screens/settings_screen__user_profile__3.dart';
import 'package:flutter_camera_example/widgets/dropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../widgets/tooltiptextfield.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _extraInfoController = TextEditingController();
  bool _wantLogo = true;
  bool _wantProfilePicture = true;
  File? _logoImage;
  File? _profileImage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _extraInfoController.dispose();
    super.dispose();
  }

  void _showTextInfoPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Helper Information'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showInfoPopup(BuildContext context, String message, RenderBox box) {
    final overlay = Overlay.of(context);
    final offset = box.localToGlobal(Offset.zero);

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy - (message.length * 1.15),
        left: offset.dx,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Widget _buildTextField(
      BuildContext context, String label, TextEditingController controller,
      {String? placeholder, String? helperText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixIcon: GestureDetector(
                onTap: () {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  _showTextInfoPopup(
                      context, helperText ?? 'Helper text not provided');
                },
                child: const Icon(Icons.help_outline, color: Colors.blue),
              ),
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, bool isLogo) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      // Here you would typically handle the picked image
      // For example, you might want to upload it to a server or store it locally
      // For now, we'll just print a message
      print('Image selected: ${pickedFile.path}');
      // You can add more logic here to handle the selected image
    }
  }

  Widget _buildUploadButton(String label, bool enabled, bool isLogo) {
    return ElevatedButton(
      onPressed: enabled ? () => _showImageSourceBottomSheet(isLogo) : null,
      child: Text(
        label,
        style: TextStyle(color: Colors.blue.shade700),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.blue.shade100,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
      ),
    );
  }

  void _showImageSourceBottomSheet(bool isLogo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('גלריה'),
                onTap: () {
                  _pickImage(ImageSource.gallery, isLogo);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('מצלמה'),
                onTap: () {
                  _pickImage(ImageSource.camera, isLogo);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: TextButton(
              child: const Text('יציאה', style: TextStyle(color: Colors.black)),
              onPressed: () {
                // Handle exit action
              },
            ),
            title: const Text('הגדרות פרופיל',
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            pinned: true,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: Column(
                children: [
                  _buildProgressTracker(),
                  _buildOutroPreview(),
                ],
              ),
              minHeight: 315,
              maxHeight: 315,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFieldWithTooltip(
                      label: 'שם מלא',
                      controller: _nameController,
                      placeholder: 'הכנס את שמך המלא',
                      helperText: 'יש להזין שם פרטי ושם משפחה מלאים',
                    ),
                    TextFieldWithTooltip(
                      label: 'מספר טלפון',
                      controller: _phoneController,
                      placeholder: 'הכנס את מספר הטלפון שלך',
                      helperText: 'יש להזין מספר טלפון תקין כולל קידומת',
                    ),
                    TextFieldWithTooltip(
                      label: 'אימייל',
                      controller: _emailController,
                      placeholder: 'הכנס את כתובת האימייל שלך',
                      helperText: 'יש להזין כתובת אימייל תקינה',
                    ),
                    TextFieldWithTooltip(
                      label: 'אתר אינטרנט',
                      controller: _websiteController,
                      placeholder: 'הכנס את כתובת האתר שלך',
                      helperText:
                          'יש להזין כתובת אתר מלאה כולל http:// או https://',
                    ),
                    TextFieldWithTooltip(
                      label: 'מידע נוסף (למשל, דרישות חוקיות)',
                      controller: _extraInfoController,
                      placeholder: 'הכנס מידע נוסף אם נדרש',
                      helperText: 'כאן ניתן להוסיף כל מידע נוסף שרלוונטי לבקשה',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child:
                              _buildUploadButton('העלאת לוגו', _wantLogo, true),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 1,
                          child: Builder(
                            builder: (BuildContext context) {
                              return ElevatedButton(
                                onPressed: () {
                                  final RenderBox box =
                                      context.findRenderObject() as RenderBox;
                                  _showInfoPopup(
                                      context, 'יש לכתוב את ההסבר כאן...', box);
                                },
                                child: const Text(
                                  '?',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(25, 50),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      title: const Text('לא רוצה לוגו'),
                      value: !_wantLogo,
                      onChanged: (value) => setState(() => _wantLogo = !value!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildUploadButton(
                              'העלאת תמונת פרופיל', _wantProfilePicture, false),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 1,
                          child: Builder(
                            builder: (BuildContext context) {
                              return ElevatedButton(
                                onPressed: () {
                                  final RenderBox box =
                                      context.findRenderObject() as RenderBox;
                                  _showInfoPopup(
                                      context, 'יש לכתוב את ההסבר כאן...', box);
                                },
                                child: const Text('?'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(50, 50),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      title: const Text('לא רוצה תמונת פרופיל'),
                      value: !_wantProfilePicture,
                      onChanged: (value) =>
                          setState(() => _wantProfilePicture = !value!),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ערכת נושא',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: buildGeneralDropdown(
                              options: [
                                DropdownOption(value: 'dark', label: 'כהה'),
                                DropdownOption(value: 'light', label: 'בהיר'),
                                DropdownOption(
                                    value: 'default',
                                    label: 'ברירת מחדל של המערכת')
                              ],
                              onChanged: (String? value) {
                                print(value);
                              }),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 1,
                          child: Builder(
                            builder: (BuildContext context) {
                              return ElevatedButton(
                                onPressed: () {
                                  final RenderBox box =
                                      context.findRenderObject() as RenderBox;
                                  _showInfoPopup(
                                      context, 'יש לכתוב את ההסבר כאן...', box);
                                },
                                child: const Text('?'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(50, 50),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 0, height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('הקודם'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.blue[700],
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.blue[700]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle next action
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const PreviewSettingsScreen()),
                                );
                              },
                              child: const Text('הבא',
                                  style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTracker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressStep(1, '', false),
          _buildProgressStep(2, 'כרטיס ביקור', true),
          _buildProgressStep(3, '', false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 33,
          height: 33,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue[700] : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ),
        if (label.isNotEmpty) const SizedBox(width: 8),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue[700] : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        if (step < 3) const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildOutroPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: const Text('לוגו'),
                    ),
                    const SizedBox(height: 8),
                    const Text('שמך'),
                    const Text('(617) 430-5293'),
                    const Text('support@metter.co.il'),
                    const Text('הוסף מידע נוסף על העסק שלך כאן'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
