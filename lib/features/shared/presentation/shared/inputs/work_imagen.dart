import 'package:formz/formz.dart';

// Define input validation errors
enum WorkImagenError { empty, format, length}

// Extend FormzInput and provide the input type and error type.
class WorkImagen extends FormzInput<String, WorkImagenError> {


  // Call super.pure to represent an unmodified form input.
  const WorkImagen.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const WorkImagen.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == WorkImagenError.empty ) return 'Debe elegir o tomar una imagen.';


    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  WorkImagenError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return WorkImagenError.empty;

    return null;
  }
}