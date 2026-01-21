import 'package:flutter/material.dart';

class PopUpMensajeFinalWidget extends StatelessWidget {

  final String text;

  const PopUpMensajeFinalWidget({
    super.key, required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.purple[100],
      contentPadding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25), 
      ),
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black
        ),
      ),
    );
  }
}