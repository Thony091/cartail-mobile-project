import 'package:flutter/material.dart';

class CheckAuthStatusScreen extends StatelessWidget {

  static const String name = 'CheckAuthStatusScreen';
  const CheckAuthStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  const SizedBox.expand(
      child: Center(
        child: CircularProgressIndicator( strokeWidth: 5,),
      ),
    );
  }
}