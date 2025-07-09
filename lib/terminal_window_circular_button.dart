import 'package:flutter/material.dart';

class WindowCircularButton extends StatelessWidget {
  const WindowCircularButton({super.key, required this.color});

  final Color color;

  @override
  Widget build(final BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
