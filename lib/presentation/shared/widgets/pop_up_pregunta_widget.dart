import 'package:flutter/material.dart';

class PopUpPreguntaWidget extends StatelessWidget {

  final String pregunta;
  final Function() confirmar;
  final Function() cancelar;

  const PopUpPreguntaWidget({
    super.key, 
    required this.pregunta, 
    required this.confirmar, 
    required this.cancelar,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 246, 200, 254),
      contentPadding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25), 
      ),
      content: Text(
        pregunta,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        IconButton(
          icon: Icon(
            Icons.check,
            color: Colors.green[800],
            size: 32,
          ),
          onPressed: confirmar
        ),
        IconButton(
          icon: Icon(
            Icons.cancel_outlined,
            color: Colors.red[800],
            size: 32,
          ),
          onPressed: cancelar, 
        )
      ],
    );
  }
}