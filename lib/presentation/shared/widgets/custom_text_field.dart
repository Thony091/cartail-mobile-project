import 'package:flutter/material.dart';

/// Widget personalizado de campo de texto con formato.
class CustomTextFormField extends StatelessWidget {
  /// Etiqueta del campo de texto.
  final String? label;

  /// Sugerencia del campo de texto.
  final String? hint;

  final Widget? suffixIcon;

  /// Mensaje de error del campo de texto.
  final String? errorMessage;

  /// Indica si el texto debe ser ocultado.
  final bool obscureText;

  /// Tipo de teclado que se mostrará.
  final TextInputType? keyboardType;

  /// Función que se llama cuando cambia el contenido del campo de texto.
  final Function(String)? onChanged;

  /// Controlador del campo de texto.
  // final TextEditingController controller;

  /// Validador del campo de texto.
  final String? Function(String?)? validator;

  final int maxLines;

  final Radius borderRadius;

  /// Construye un [CustomTextFormField] con los parámetros proporcionados.
  const CustomTextFormField({
    super.key, 
    // required this.controller,
    this.suffixIcon,
    this.label, 
    this.hint, 
    this.errorMessage, 
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged, 
    this.validator, 
    this.maxLines = 1,
    this.borderRadius = const Radius.circular(0),

  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(40)
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:  BorderRadius.only(topLeft: borderRadius, bottomLeft: borderRadius, bottomRight: borderRadius ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0,5)
          )
        ]
      ),
      child: Material(
        child: TextFormField(
          maxLines: maxLines,
          onChanged: onChanged,
          // controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle( fontSize: 20, color: Colors.black54 ),
          decoration: InputDecoration(
            floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            enabledBorder: border,
            focusedBorder: border,
            errorBorder: border.copyWith( borderSide: const BorderSide( color: Colors.transparent )),
            focusedErrorBorder: border.copyWith( borderSide: const BorderSide( color: Colors.transparent )),
            isDense: true,
            label: label != null ? Text(label!) : null,
            hintText: hint,
            errorText: errorMessage,
            focusColor: colors.primary,
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}