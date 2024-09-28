import 'package:flutter/material.dart';
import 'package:flutter_camera_example/screens/settings/user-profile/step_2.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'הגדרות פרופיל',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressTracker(),
          const Padding(padding: EdgeInsets.all(16)), // Increased padding
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'עריכת משתמש',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w200,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildTextField('מספר נייד', '+972523489209'),
                      const SizedBox(height: 32),
                      _buildTextField('שם מלא', 'דוריאן'),
                      const SizedBox(height: 32),
                      _buildDropdown('בחר שפה', 'עברית'),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('יציאה'),
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
                                            const ProfileSettingsPage()),
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
              ),
            ),
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
          _buildProgressStep(1, 'פרטי משתמש', true),
          _buildProgressStep(2, '', false),
          _buildProgressStep(3, '', false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 33, // Increased size by 10%
          height: 33, // Increased size by 10%
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue[700] : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontSize: 16, // Increased font size to match the larger circle
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

  Widget _buildTextField(String label, String initialValue) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: Colors.white, // Lighter background color
        filled: true,
      ),
      controller: TextEditingController(text: initialValue),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildDropdown(String label, String initialValue) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: Colors.white, // Lighter background color
        filled: true,
      ),
      value: initialValue,
      items:
          ['עברית', 'אנגלית', 'ערבית', 'צרפתית', 'רוסית'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (_) {},
      isExpanded: true,
      alignment: AlignmentDirectional.centerEnd,
    );
  }
}
