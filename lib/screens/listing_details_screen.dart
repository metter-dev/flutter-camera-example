import 'package:flutter/material.dart';
import 'package:flutter_camera_example/screens/add-project/select_music_screen.dart';

class AddListingDetailsScreen extends StatelessWidget {
  const AddListingDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          child: const Text('חזור', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            child: const Text('הבא', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const SelectMusicScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'מידע על הנכס',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'הזן את המידע שיוצג על גבי הסרטון',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('כותרת על הסרטון'),
                  const SizedBox(height: 5),
                  _buildInputField('כתובת הנכס', icon: Icons.location_on),
                  const SizedBox(height: 5),
                  _buildInputField('מחיר הנכס (לדוגמה 500,000ש"ח)',
                      icon: Icons.attach_money),
                  const SizedBox(height: 5),
                  _buildInputField('מספר חדרי שינה', icon: Icons.bed),
                  const SizedBox(height: 5),
                  _buildInputField('מספר חדרי שרותים', icon: Icons.bathtub),
                  const SizedBox(height: 5),
                  _buildInputField('גודל במ"ר', icon: Icons.home),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: const Icon(Icons.visibility),
          border: const OutlineInputBorder(),
        ),
      ),
    );
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
                      : (index == 1 ? Colors.green : Colors.grey[300]),
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
                  color: index < 1 ? Colors.green : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }
}
