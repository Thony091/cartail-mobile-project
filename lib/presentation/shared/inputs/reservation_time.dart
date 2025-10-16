import 'package:formz/formz.dart';

// Define input validation errors
enum ReservationTimeError { empty, format }

// Extend FormzInput and provide the input type and error type.
class ReservationTime extends FormzInput<String, ReservationTimeError> {

  static final RegExp timeRegExp = RegExp(
    r'^([01]\d|2[0-3]):[0-5]\d$', // Valida horas de 00 a 23 y minutos de 00 a 59
  );

  // Call super.pure to represent an unmodified form input.
  ReservationTime.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const ReservationTime.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;

    switch (displayError) {
      case ReservationTimeError.empty:
        return 'El campo es requerido';
      case ReservationTimeError.format:
        return 'Error en el formato, debe ser HH:mm';
      default:
        return null;
    }
  }

  // Override validator to handle validating a given input value.
  @override
  ReservationTimeError? validator(String value) {
    if (value.isEmpty) return ReservationTimeError.empty;
    if (!timeRegExp.hasMatch(value)) return ReservationTimeError.format;
    return null;
  }
}
