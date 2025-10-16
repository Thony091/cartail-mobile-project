// ignore_for_file: non_constant_identifier_names

import 'package:formz/formz.dart';

// Define input validation errors
enum BirthdayError { empty, format }

// Extend FormzInput and provide the input type and error type.
class Birthday extends FormzInput<String, BirthdayError> {

  static final RegExp BirthdayRegExp = RegExp(
    r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$',
  );

  // Call super.pure to represent an unmodified form input.
  const Birthday.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Birthday.dirty( String value ) : super.dirty(value);

  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == BirthdayError.empty ) return 'El campo es requerido';
    if ( displayError == BirthdayError.format ) return 'Error en el formato, debe ser dd/mm/yyyy';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  BirthdayError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return BirthdayError.empty;
    if ( !BirthdayRegExp.hasMatch(value) ) return BirthdayError.format;

    return null;
  }
}