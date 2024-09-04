import 'package:flutter/material.dart';
import 'package:flutter_camera_example/screens/camera_screen.dart';
import 'package:flutter_camera_example/services/global_state.dart';
import 'package:provider/provider.dart';


class OrientationSelectionScreen extends StatelessWidget {
  const OrientationSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
leading: TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            backgroundColor: Colors.transparent,
          ),
          child: const Text(
            'יציאה',
            style: TextStyle(
              color: Colors.black,
            ),
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Colors.transparent,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ));
              },
              child: const Text(
                'הבא',
                style: TextStyle(color: Colors.black),
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'כיוון הקלטה',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'יש לבחור את מנח המכשיר כדי לצלם סרטונים',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(width: 16, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OrientationOption(
                  icon: Icons.stay_current_landscape,
                  label: 'לרוחב',
                  orientation: CameraOrientation.landscape,
                ),
                SizedBox(
                  width: 16,
                  height: 32,
                ),
                _OrientationOption(
                  icon: Icons.stay_current_portrait,
                  label: 'לאורך',
                  orientation: CameraOrientation.portrait,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _OrientationOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final CameraOrientation orientation;

  const _OrientationOption({
    required this.icon,
    required this.label,
    required this.orientation,
  });

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppStateModel>(context);
    final selectedOrientation = app.preferences.selectedOrientation;

    final isSelected = selectedOrientation == orientation;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => GlobalState.setOrientation(orientation),
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 175,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? const Color.fromARGB(255, 76, 116, 175)
                  : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 80,
                  color: isSelected
                      ? const Color.fromARGB(255, 76, 116, 175)
                      : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color.fromARGB(255, 76, 116, 175)
                        : Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
