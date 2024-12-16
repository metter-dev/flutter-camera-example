import 'package:flutter/material.dart';

class Template {
  final int index;
  final String name;
  final Widget Function() buildWidget;

  Template({
    required this.index,
    required this.name,
    required this.buildWidget,
  });
}

final List<Template> templates = [
  Template(
    index: 0,
    name: 'Agent Template',
    buildWidget: () =>
        _buildTemplateForAgents(imgPath: 'assets/home_interior.avif'),
  ),
  Template(
    index: 1,
    name: 'Preview Template',
    buildWidget: () => _buildTemplatePreview(isFirstTemplate: true),
  ),
  Template(
    index: 2,
    name: 'Agent Template',
    buildWidget: () =>
        _buildTemplateForAgents(imgPath: 'assets/templates/3.png'),
  ),
  Template(
      index: 3,
      name: '4',
      buildWidget: () =>
          _buildTemplateForAgents(imgPath: 'assets/templates/4.png')),
  Template(
      index: 4,
      name: '5',
      buildWidget: () =>
          _buildTemplateForAgents(imgPath: 'assets/templates/5.png')),
  Template(
      index: 5,
      name: '6',
      buildWidget: () =>
          _buildTemplateForAgents(imgPath: 'assets/templates/6.png'))
];

Widget _buildTemplatePreview({required bool isFirstTemplate}) {
  return Stack(
    children: [
      Image.asset('assets/templates/template_example.png'),
      const Positioned(
        top: 8,
        right: 8,
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/templates/template_example.png'),
          radius: 20,
        ),
      ),
    ],
  );
}

Widget _buildTemplateForAgents({
  required String imgPath,
}) {
  return GestureDetector(
    child: Stack(
      children: [
        Image.asset(imgPath),
        Positioned(
          bottom: 12,
          right: 12,
          child: Image(
            image: AssetImage(imgPath),
            width: 60,
          ),
        ),
      ],
    ),
  );
}
