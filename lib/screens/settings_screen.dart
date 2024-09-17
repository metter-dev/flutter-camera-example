import 'package:flutter/material.dart';

import 'settings_screen__user_profile__1.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FAB press
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 76, 116, 175),
        shape: const CircleBorder(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'הגדרות',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'פרופיל',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Already on settings screen
          } else if (index == 1) {
            print('ניווט למסך הפרופיל');
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSettingItem(IconData icon, String title, context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
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
