// ignore_for_file: non_constant_identifier_names

import 'package:formz/formz.dart';

// Define input validation errors
enum RutError { empty, format, length}

// Extend FormzInput and provide the input type and error type.
class Rut extends FormzInput<String, RutError> {

  static final RegExp RutRegExp = RegExp(
    r'^\d{7,8}-[\dK]$',
  );

  // Call super.pure to represent an unmodified form input.
  const Rut.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Rut.dirty( String value ) : super.dirty(value);

  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == RutError.empty ) return 'El campo es requerido';
    // if ( displayError == RutError.format ) return 'Error en el formato';
    if ( displayError == RutError.format ) return 'El RUT debe tener 7 o 8 dígitos y un guión y un dígito verificador';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  RutError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return RutError.empty;
    if ( !RutRegExp.hasMatch(value) ) return RutError.format;

    return null;
  }
}