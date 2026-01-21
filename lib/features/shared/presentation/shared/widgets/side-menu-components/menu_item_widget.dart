import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuItemWidget extends StatelessWidget {

  final MenuItemData item;

  const MenuItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).subloc;
    final isActive = currentRoute == item.route;

    return AnimatedContainer(
      duration: const Duration( milliseconds: 200 ),
      margin: const EdgeInsets.symmetric(
        horizontal: 12, 
        vertical: 2
      ),
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFF3498db).withValues( alpha: .1 ) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive 
            ? Border.all(
                color: const Color(0xFF3498db).withValues( alpha: .3 )
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          isActive 
            ? item.activeIcon 
            : item.icon,
          color: isActive 
              ? const Color(0xFF3498db) 
              : const Color(0xFF7f8c8d),
          size: 22,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive 
                ? const Color(0xFF3498db) 
                : const Color(0xFF2c3e50),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isActive 
              ? const Color(0xFF3498db) 
              : const Color(0xFF7f8c8d),
          size: 18,
        ),
        onTap: item.onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

}

class MenuItemData {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final VoidCallback onTap;
  final String? route;

  MenuItemData({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.onTap,
    this.route,
  });
}
