import 'package:flutter/material.dart';

class ModernFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final double size;

  const ModernFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    final iconSize = size * 0.43;
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFf39c12), Color(0xFFe67e22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFf39c12).withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
