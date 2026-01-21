import 'package:flutter/material.dart';

class BackgroundImageWidget extends StatelessWidget {
  final Widget child; 
  final double? opacity;
  final String? image;
  final Color? startColor;
  final Color? endColor;

  const BackgroundImageWidget({
    super.key, 
    required this.child, 
    this.opacity, 
    this.image,
    this.startColor,
    this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: size.height,
          child: Container(
            decoration:  BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  startColor ?? Colors.black26,
                  endColor ?? const Color.fromARGB(255, 233, 227, 227),
                ],
              ),
            ),  
          ),
        ),
        Center(
          child: Opacity(
            opacity: opacity!,
            child: Image.asset(
              'assets/logo/logo-second-no-bg.png',
              // 'assets/icons/AR_2.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
