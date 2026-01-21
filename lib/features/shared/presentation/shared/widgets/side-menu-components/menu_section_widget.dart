import 'package:flutter/material.dart';

import 'menu_item_widget.dart';

class MenuSectionWidget extends StatelessWidget {
  final String title;
  final List<MenuItemData> items;

  const MenuSectionWidget({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7f8c8d),
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items.map((item) => MenuItemWidget(item:item)),
        // ...items.map((item) => _buildMenuItem(item)),
        const SizedBox(height: 8),
      ],
    );
  }
}