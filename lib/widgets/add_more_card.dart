import 'package:flutter/material.dart';

class AddMoreCard extends StatelessWidget {
  final VoidCallback onTap;
  final Function(String type)? onSelect;

  const AddMoreCard({
    Key? key,
    required this.onTap,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: SizedBox(
        height: 180,
        child: Column(
          children: [
            Expanded(
              child: _buildOption(
                icon: Icons.photo_library,
                label: 'Upload Photos',
                onPressed: () => onSelect!('upload') ?? onTap(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _buildOption(
                icon: Icons.camera_alt,
                label: 'Take Photo',
                onPressed: () => onSelect?.call('camera') ?? onTap(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _buildOption(
                icon: Icons.videocam,
                label: 'Record Video',
                onPressed: () => onSelect?.call('video') ?? onTap(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
