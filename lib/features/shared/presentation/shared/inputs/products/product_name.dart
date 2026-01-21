import 'package:formz/formz.dart';

// Define input validation errors
enum ProductNameError { empty }

// Extend FormzInput and provide the input type and error type.
class ProductName extends FormzInput<String, ProductNameError> {


  // Call super.pure to represent an unmodified form input.
  const ProductName.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const ProductName.dirty( String value ) : super.dirty(value);



  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == ProductNameError.empty ) return 'El campo es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  ProductNameError? validator(String value) {
    
    if ( value.isEmpty || value.trim().isEmpty ) return ProductNameError.empty;

    return null;
  }
}