import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DeviceSideDetector extends StatefulWidget {
  const DeviceSideDetector({Key? key}) : super(key: key);

  @override
  _DeviceSideDetectorState createState() => _DeviceSideDetectorState();
}

class _DeviceSideDetectorState extends State<DeviceSideDetector> {
  String _currentSide = "Unknown";

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      // Threshold for detecting if a side is facing down (slightly less than gravity)
      const double threshold = 9.0;

      String newSide = "Unknown";

      // Check which axis has highest gravity reading
      if (event.z.abs() > threshold) {
        newSide = event.z > 0 ? "Back" : "Screen";
      } else if (event.x.abs() > threshold) {
        newSide = event.x > 0 ? "Right Side" : "Left Side";
      } else if (event.y.abs() > threshold) {
        newSide = event.y > 0 ? "Bottom" : "Top";
      }

      if (newSide != _currentSide) {
        setState(() {
          _currentSide = newSide;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Side Detector'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Device is resting on:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              _currentSide,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
