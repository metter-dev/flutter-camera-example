import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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
