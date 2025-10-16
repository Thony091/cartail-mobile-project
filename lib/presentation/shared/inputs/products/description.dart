import 'package:formz/formz.dart';

// Define input validation errors
enum DescriptionError { empty, format, length }

// Extend FormzInput and provide the input type and error type.
class Description extends FormzInput<String, DescriptionError> {


  // Call super.pure to represent an unmodified form input.
  const Description.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Description.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == DescriptionError.empty ) return 'El campo es requerido';

    if ( displayError == DescriptionError.length ) return 'El mensaje no puede superar los 500 caracteres';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  DescriptionError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return DescriptionError.empty;
    if ( value.length >= 500 ) return DescriptionError.length;

    return null;
  }
}