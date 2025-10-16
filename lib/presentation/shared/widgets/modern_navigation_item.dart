import 'package:flutter/material.dart';

class ModernNavigationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isActive;
  final bool showArrow;

  const ModernNavigationItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isActive = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3498db).withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? const Border(
                left: BorderSide(
                  color: Color(0xFF3498db),
                  width: 4,
                ),
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF3498db)
                        : const Color(0xFF95a5a6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : const Color(0xFF7f8c8d),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFF3498db)
                              : const Color(0xFF2c3e50),
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                    ],
                  ),
                ),
                if (showArrow)
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFF7f8c8d).withOpacity(0.5),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
