import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Botón flotante movible para debug que accede al Connectivity Monitor
/// Solo visible en modo debug
class DebugFabButton extends StatefulWidget {
  const DebugFabButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  State<DebugFabButton> createState() => _DebugFabButtonState();
}

class _DebugFabButtonState extends State<DebugFabButton> {
  late Offset position = const Offset(16, 100);
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    // Solo mostrar en debug
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            isDragging = true;
            position = Offset(
              position.dx + details.delta.dx,
              position.dy + details.delta.dy,
            );
          });
        },
        onPanEnd: (details) {
          setState(() {
            isDragging = false;
          });
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Material(
            shape: const CircleBorder(),
            elevation: isDragging ? 8 : 4,
            color: Colors.purple[700],
            child: InkWell(
              onTap: widget.onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple[700],
                ),
                child: const Icon(
                  Icons.bug_report_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
