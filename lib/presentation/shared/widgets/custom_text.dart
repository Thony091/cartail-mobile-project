import 'package:flutter/material.dart';

import '../../../config/config.dart';

class CustomTextWithEffect extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  const CustomTextWithEffect({
    Key? key, 
    required this.text, 
    required this.textStyle,
  }) : super(key: key);

  @override
  State<CustomTextWithEffect> createState() => _CustomTextWithEffectState();
}

class _CustomTextWithEffectState extends State<CustomTextWithEffect> with SingleTickerProviderStateMixin{

  // late AnimationController _controller;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = AnimationController(
  //     duration: const Duration(seconds: 5),
  //     vsync: this,
  //   );
  // }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    
    final color = AppTheme().getTheme().colorScheme;

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [ Colors.white70,color.primary, color.primary],  
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: const [0.1, .9, 2],
          tileMode: TileMode.mirror,
          // transform: GradientRotation(_controller.value * 2 * 3.141592653589793),
        ).createShader(bounds);
      },
      child: Text(
        widget.text,
        style: widget.textStyle.copyWith(
          color: Colors.white,
          shadows: [
            const Shadow(
              offset: Offset(1.0, 3.0),
              blurRadius: 3.0,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
