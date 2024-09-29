import 'package:flutter/material.dart';
import 'package:flutter_camera_example/utils/global_state.dart';

class VideoSettingsScreen extends StatefulWidget {
  const VideoSettingsScreen({Key? key}) : super(key: key);

  @override
  _VideoSettingsScreenState createState() => _VideoSettingsScreenState();
}

class _VideoSettingsScreenState extends State<VideoSettingsScreen> {
  String videoQuality = GlobalState.getProfileAttribute('videoFPS') ?? '1080p';
  String videoFPS = GlobalState.getProfileAttribute('videoFPS') ?? '60 fps';
  String videoStabilization = 'אוטומטי';
  bool stabilizerFriendly = false;
  bool countdownTimer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('86%', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text('4G', style: TextStyle(fontSize: 12)),
                SizedBox(width: 4),
                Text('LTE', style: TextStyle(fontSize: 12)),
                SizedBox(width: 4),
                Text('345 KB/s', style: TextStyle(fontSize: 12)),
                SizedBox(width: 4),
                Icon(Icons.sync, size: 16),
              ],
            ),
            Text('19:48', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('הגדרות וידאו',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('סיום',
                    style: TextStyle(color: Colors.green, fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSettingItem(
                  'איכות וידאו',
                  videoQuality,
                  'הגדלת האיכות תייצר סרטונים הנראים טוב יותר על חשבון מקום שנלקח במכשיר שלך וזמן עיבוד ארוך יותר',
                    () async {
                  _showOptionDialog(
                      'איכות וידאו',
                      ['720p', '1080p', '4K'],
                      (value) async {
                    setState(() => videoQuality = value);
                    GlobalState.addProfileAttribute('videoFPS', videoQuality);
                  });
                }
                ),
                _buildSettingItem(
                  'קצב פריימים',
                  videoFPS,
                  'הגדלת קצב הפריימים תייצר סרטונים חלקים יותר על חשבון מקום שנלקח במכשיר שלך וזמן עיבוד ארוך יותר.',
                  () => _showOptionDialog(
                      'קצב פריימים',
                      ['24 fps', '30 fps', '60 fps'],
                      (value) => setState(() => videoFPS = value)),
                ),
                _buildSettingItem(
                  'ייצוב וידאו',
                  videoStabilization,
                  'ניתן להחיל ייצוב על סרטונים שהוקלטו באמצעות Momenzo. "מופעל" מומלץ. לא כל המצלמות תומכות בייצוב ובחירת מצב שאינו נתמך תגרום לחוסר ייצוב.',
                  () => _showOptionDialog(
                      'ייצוב וידאו',
                      ['כבוי', 'מופעל', 'אוטומטי'],
                      (value) => setState(() => videoStabilization = value)),
                ),
                _buildSwitchItem(
                  'ידידותי למייצב',
                  'מסך ההקלטה יותאם לשימוש עם מייצב',
                  stabilizerFriendly,
                  (value) => setState(() => stabilizerFriendly = value),
                ),
                _buildSwitchItem(
                  'טיימר ספירה לאחור',
                  'הוסף 3 שניות ספירה לאחור כדי להתכונן להקלטה לפני כל צילום',
                  countdownTimer,
                  (value) => setState(() => countdownTimer = value),
                ),
                _buildInfoItem('גודל פרויקטים', "13 ב'"),
                _buildInfoItem('גרסה', '(288) 3.2.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      String title, String value, String description, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.chevron_left, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(value,
                              style: const TextStyle(color: Colors.green)),
                        ],
                      ),
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
      String title, String description, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _showOptionDialog(
      String title, List<String> options, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((option) => ListTile(
                      title: Text(option),
                      onTap: () {
                        onSelect(option);
                        Navigator.of(context).pop();
                      },
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              child: const Text('ביטול'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
