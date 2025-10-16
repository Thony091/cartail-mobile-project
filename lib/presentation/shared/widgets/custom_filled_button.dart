
import 'package:flutter/material.dart';

/// Widget personalizado de botón relleno.
class CustomFilledButton extends StatelessWidget {
  /// La función de devolución de llamada que se ejecutará cuando se presione el botón.
  final void Function()? onPressed;
  /// El icono que se mostrará en el botón.
  final IconData icon;
  /// El texto que se mostrará en el botón.
  final String text;
  /// El color de fondo del botón.
  final Color? buttonColor;
  /// La altura del botón.
  final double? height;
  /// El ancho del botón.
  final double? width;
  /// El radio de las esquinas del botón.
  final Radius radius;
  /// El color de la sombra del botón.
  final Color shadowColor;
  /// El radio de dispersión de la sombra.
  final double spreadRadius;
  /// El radio de desenfoque de la sombra.
  final double blurRadius;
  /// El desplazamiento horizontal de la sombra.
  final double offsetX;
  /// El desplazamiento vertical de la sombra.
  final double offsetY;
  /// El relleno del botón.
  final EdgeInsets padding;
  /// El tamaño de la fuente del texto del botón.
  final double fontSize;
  /// El color del texto del botón.
  final Color textColor;
  /// La alineación principal del botón.
  final MainAxisAlignment mainAxisAlignment;
  /// El ancho del separador del icono.
  final double iconSeparatorWidth;
  /// El gradiente del botón.
  final Gradient? gradient;

  /// Construye un [CustomFilledButton] con los parámetros proporcionados.
  const CustomFilledButton({
    super.key, 
    this.icon = Icons.add,
    required this.text, 
    this.onPressed, 
    this.buttonColor, 
    this.height, 
    this.width, 
    this.radius = const Radius.circular(0), 
    this.shadowColor = Colors.transparent, 
    this.spreadRadius = 0.0, 
    this.blurRadius = 0.0, 
    this.offsetX = 0.0, 
    this.offsetY = 0.0, 
    this.padding = const EdgeInsets.all(0),
    this.fontSize = 16,
    this.textColor = Colors.white,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.iconSeparatorWidth = 0.0,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {

    // const radius = Radius.circular(10);

    return Padding(
      padding: padding,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: radius,
            bottomRight: radius,
            topLeft: radius,
            topRight: radius,
          ),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              spreadRadius: spreadRadius,
              blurRadius: blurRadius,
              offset: Offset(offsetX, offsetY),
            ),
          ],
        ),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: radius,
                bottomRight: radius,
                topLeft: radius,
                topRight: radius,
              ),
            )),
            
          onPressed: onPressed, 
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: mainAxisAlignment,
            children: [
              Icon( icon, color: Colors.orangeAccent),
              SizedBox(width: iconSeparatorWidth),
              Text(
                text, 
                style: TextStyle(
                  fontSize: fontSize, 
                  color: textColor
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}