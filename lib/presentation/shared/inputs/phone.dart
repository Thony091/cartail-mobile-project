// ignore_for_file: non_constant_identifier_names

import 'package:formz/formz.dart';

// Define input validation errors
enum PhoneError { empty, format, length}

// Extend FormzInput and provide the input type and error type.
class Phone extends FormzInput<String, PhoneError> {

  static final RegExp PhoneRegExp = RegExp(
    r'^\d{9}$',
  );

  // Call super.pure to represent an unmodified form input.
  const Phone.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Phone.dirty( String value ) : super.dirty(value);

  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == PhoneError.empty ) return 'El campo es requerido';
    // if ( displayError == PhoneError.format ) return 'Error en el formato, deben ser dígitos';
    if ( displayError == PhoneError.length ) return 'El teléfono debe tener 9 dígitos';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  PhoneError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return PhoneError.empty;
    if ( !PhoneRegExp.hasMatch(value) ) return PhoneError.length;

    return null;
  }
}