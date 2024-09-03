import 'package:flutter/material.dart';

class RecordingIndicator extends StatelessWidget {
  final int duration;

  const RecordingIndicator({Key? key, required this.duration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.fiber_manual_record, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              '${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
