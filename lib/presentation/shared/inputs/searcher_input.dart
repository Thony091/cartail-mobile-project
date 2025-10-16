import 'package:formz/formz.dart';

/// Enumeración que define los posibles errores de validación para el campo de búsqueda de patente.
enum SearcherInputError { empty, length, format}

// Extend FormzInput and provide the input type and error type.
class SearcherInputByPatent extends FormzInput<String, SearcherInputError > {

  // Call super.pure to represent an unmodified form input.
  const SearcherInputByPatent.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const SearcherInputByPatent.dirty( String value ) : super.dirty(value);

  // Obtiene el mensaje de error según el estado del campo.
  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == SearcherInputError.empty ) return 'El campo es requerido';
    if ( displayError == SearcherInputError.length ) return 'Mínimo 6 caracteres';
    if ( displayError == SearcherInputError.format ) return 'Debe cumplir el formato de patente';

    return null;
  }


  // Override validator to handle validating a given input value.
  @override
  SearcherInputError? validator(String value) {

    if ( !value.contains( RegExp(r'[b-df-hj-np-tv-zB-DF-HJ-NP-TV-Z]{2}\d{4}$|[b-df-hj-np-tv-zB-DF-HJ-NP-TV-Z]{4}\d{2}$')))return SearcherInputError.format;
    if ( value.isEmpty || value.trim().isEmpty ) return SearcherInputError.empty;
    if ( value.length < 6 ) return SearcherInputError.length;    

    return null;
  }
}

/// Clase que extiende `FormzInput` y proporciona el tipo de entrada y el tipo de error para el campo de búsqueda general.
class SearcherInput extends FormzInput<String, SearcherInputError > {

  // Call super.pure to represent an unmodified form input.
  const SearcherInput.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const SearcherInput.dirty( String value ) : super.dirty(value);

  // Obtiene el mensaje de error según el estado del campo.
  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == SearcherInputError.empty ) return 'El campo es requerido';
    if ( displayError == SearcherInputError.length ) return 'Mínimo 6 caracteres';
    if ( displayError == SearcherInputError.format ) return 'Debe cumplir el formato, solo números o letras';

    return null;
  }


  // Override validator to handle validating a given input value.
  @override
  SearcherInputError? validator(String value) {

    if ( !value.contains( RegExp(r'^[a-zA-Z0-9 -]*$')))return SearcherInputError.format;
    if ( value.isEmpty || value.trim().isEmpty ) return SearcherInputError.empty;
    if ( value.length < 6 ) return SearcherInputError.length;
    
    return null;
  }
}