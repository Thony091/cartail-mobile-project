import 'package:flutter/material.dart';

class ServiceHighlightWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const ServiceHighlightWidget({
    super.key, 
    required this.icon, 
    required this.title, 
    required this.description, 
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7f8c8d),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}