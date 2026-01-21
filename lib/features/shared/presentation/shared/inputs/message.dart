import 'package:formz/formz.dart';

// Define input validation errors
enum MessagesError { empty, format, length }

// Extend FormzInput and provide the input type and error type.
class Messages extends FormzInput<String, MessagesError> {

  static final RegExp messageRegExp = RegExp(
    r'^[A-Za-z].{0,349}$',
  );

  // Call super.pure to represent an unmodified form input.
  const Messages.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Messages.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == MessagesError.empty ) return 'El campo es requerido';
    // if ( displayError == MessagesError.format ) return 'El mensaje no cumple con el formato requerido';
    if ( displayError == MessagesError.length ) return 'El mensaje no puede superar los 350 caracteres';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  MessagesError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return MessagesError.empty;
    // if ( !messageRegExp.hasMatch(value)) return MessagesError.format;
    if ( value.length >= 350 ) return MessagesError.length;

    return null;
  }
}