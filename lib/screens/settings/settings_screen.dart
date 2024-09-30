import 'package:flutter/material.dart';
import 'package:flutter_camera_example/screens/settings/video_settings_screen.dart';

import '../add-project/orientation_selection_screen.dart';
import 'user-profile/step_1.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('מֵטר', style: TextStyle(fontSize: 42)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Material(
        color: Colors.transparent,
        child: ListView(
          children: [
            const Padding(padding: EdgeInsets.all(6)),
            _buildSettingItem(Icons.person_outline, 'הגדרות פרופיל', context),
            _buildSettingItem(Icons.video_settings, 'הגדרות וידאו', context),
            _buildSettingItem(
                Icons.play_circle_outline, 'גישה ל-YouTube', context),
            _buildSettingItem(Icons.lock_outline, 'הגדרות חשבון', context),
            _buildSettingItem(Icons.star_border, 'מנוי', context),
            _buildSettingItem(Icons.info_outline, 'תנאי שימוש', context),
            _buildSettingItem(Icons.shield_outlined, 'מדיניות פרטיות', context),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 0), // Adjust this value as needed
        child: SizedBox(
          width: 96,
          height: 96,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OrientationSelectionScreen()),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 40),
            backgroundColor: const Color.fromARGB(255, 76, 116, 175),
            shape: const CircleBorder(),
          ),
        ),
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings),
                  Text('הגדרות'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person),
                  Text('פרופיל'),
                ],
              ),
            ),
          ],
        ),
      ],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget getScreen(String title) {
    if (title == 'הגדרות וידאו') {
      return const VideoSettingsScreen();
    }

    return const ProfileSettingsScreen();
  }

  Widget _buildSettingItem(IconData icon, String title, context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => getScreen(title)),
        )
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Material(
          color: Colors.white,
          elevation: 1,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            leading: Icon(icon, color: Colors.green),
            title: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textDirection: TextDirection.rtl,
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }
}
