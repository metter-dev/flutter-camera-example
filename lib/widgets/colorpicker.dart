import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerWidget extends StatefulWidget {
  final Function(Color?) onColorChanged;
  final Color? initialColor;

  const ColorPickerWidget({
    Key? key,
    required this.onColorChanged,
    this.initialColor,
  }) : super(key: key);

  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('בחר צבע'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor ?? Colors.blue,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('אישור'),
              onPressed: () {
                widget.onColorChanged(_selectedColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetColor() {
    setState(() {
      _selectedColor = null;
    });
    widget.onColorChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          if (_selectedColor != null)
            Container(
              width: 30,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              _selectedColor != null
                  ? '#${_selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}'
                  : 'בחר צבע',
              style: TextStyle(
                  color: _selectedColor != null ? Colors.black : Colors.grey),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _openColorPicker,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _resetColor,
          ),
        ],
      ),
    );
  }
}
