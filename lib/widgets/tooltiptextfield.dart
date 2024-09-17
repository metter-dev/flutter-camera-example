import 'package:flutter/material.dart';
import 'dart:async';

class TooltipShape extends ShapeBorder {
  final double arrowWidth = 20.0;
  final double arrowHeight = 10.0;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
          rect.deflate(arrowHeight), const Radius.circular(12)))
      ..moveTo(rect.bottomCenter.dx - arrowWidth / 2, rect.bottom - arrowHeight)
      ..relativeLineTo(arrowWidth / 2, arrowHeight)
      ..relativeLineTo(arrowWidth / 2, -arrowHeight)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

class TextFieldWithTooltip extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final String? helperText;

  const TextFieldWithTooltip({
    Key? key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.helperText,
  }) : super(key: key);

  @override
  _TextFieldWithTooltipState createState() => _TextFieldWithTooltipState();
}

class _TextFieldWithTooltipState extends State<TextFieldWithTooltip> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isTooltipVisible = false;
  Timer? _tooltipTimer;

  void _showTooltip() {
    final overlay = Overlay.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final tooltipWidth = screenWidth * 0.8;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: tooltipWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset:
              Offset((tooltipWidth) / 10 - 20, -65), // Centered, above the icon
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: ShapeDecoration(
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                shape: TooltipShape(),
              ),
              child: Text(
                widget.helperText ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isTooltipVisible = true);

    // Auto-close after 3 seconds
    _tooltipTimer = Timer(const Duration(seconds: 3), () {
      _hideTooltip();
    });
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _tooltipTimer?.cancel();
    setState(() => _isTooltipVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          CompositedTransformTarget(
            link: _layerLink,
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: _isTooltipVisible ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    if (_isTooltipVisible) {
                      _hideTooltip();
                    } else {
                      _showTooltip();
                    }
                  },
                ),
                hintText: widget.placeholder,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }
}
