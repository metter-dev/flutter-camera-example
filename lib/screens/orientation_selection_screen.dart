import 'package:flutter/material.dart';

class OrientationSelectionScreen extends StatefulWidget {
  const OrientationSelectionScreen({Key? key}) : super(key: key);

  @override
  _OrientationSelectionScreenState createState() =>
      _OrientationSelectionScreenState();
}

class _OrientationSelectionScreenState
    extends State<OrientationSelectionScreen> {
  bool isPortrait = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: TextButton(
          child: const Text('יציאה',
              style: TextStyle(
                color: Colors.black,
              )),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('הבא',
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'כיוון הקלטה',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'יש לבחור את מנח המכשיר כדי לצלם סרטונים',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 16, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OrientationOption(
                  icon: Icons.stay_current_landscape,
                  label: 'לרוחב',
                  isSelected: !isPortrait,
                  onTap: () => setState(() => isPortrait = false),
                ),
                const SizedBox(
                  width: 16,
                  height: 32,
                ),
                _OrientationOption(
                  icon: Icons.stay_current_portrait,
                  label: 'לאורך',
                  isSelected: isPortrait,
                  onTap: () => setState(() => isPortrait = true),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _OrientationOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
