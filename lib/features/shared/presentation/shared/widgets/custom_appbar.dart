import 'package:flutter/material.dart';
import 'package:portafolio_project/config/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextStyle? styleText;
  final Radius topRadius;
  final Radius bottomRadius;
  final IconData? customIcon;
  final double iconSize;
  final VoidCallback? onIconPressed;
  final Color? iconColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.styleText = const TextStyle(
      color: Colors.black, 
      fontSize: 20, 
      fontWeight: FontWeight.w500,
    ),
    this.topRadius = const Radius.circular(0),
    this.bottomRadius = const Radius.circular(0),
    this.customIcon,
    this.iconSize = 20,
    this.iconColor,
    this.onIconPressed, 
  });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    const double iconLeftPadding = 10;
    
    return Container(
      height: size.height * 0.1,
      // height: kToolbarHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.goldGradientColors,
          stops: AppTheme.goldGradientStops,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: bottomRadius, 
          bottomRight: bottomRadius,
          topLeft: topRadius,
          topRight: topRadius,
        ), 
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onIconPressed, 
            child:  Padding(
              padding: const EdgeInsets.only(top: 12, left: iconLeftPadding),
              child: Icon(
                customIcon, 
                color: iconColor,
                size: iconSize,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only( top: 12,),
              child: Center(
                child: Text(
                  title,
                  style: styleText?.copyWith( fontWeight: FontWeight.bold ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox( width: iconSize + iconLeftPadding,)
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
