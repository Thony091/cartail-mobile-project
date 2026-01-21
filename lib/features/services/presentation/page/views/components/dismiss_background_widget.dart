import 'package:flutter/material.dart';

class DismissBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;

  const DismissBackground({
    super.key,
    required this.color,
    required this.icon,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
