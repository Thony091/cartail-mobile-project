import 'package:formz/formz.dart';
import 'package:intl/intl.dart';

// Define input validation errors
enum ReservationDateError { empty, format, futureDate }

// Extend FormzInput and provide the input type and error type.
class ReservationDate extends FormzInput<String, ReservationDateError> {

  static final RegExp reservationDayRegExp = RegExp(
    r'^(\d{4})-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$',
    // r'^(0[1-9]|[12][0-9]|3[01])([-/])(0[1-9]|1[012])\2\d{4}$',
  );

  // Call super.pure to represent an unmodified form input.
  ReservationDate.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const ReservationDate.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;

    switch (displayError) {
      case ReservationDateError.empty:
        return 'El campo es requerido';
      case ReservationDateError.format:
        return 'Error en el formato, debe ser yyyy-mm-dd';
      case ReservationDateError.futureDate:
        return 'La fecha debe ser futura';
      default:
        return null;
    }
  }

  // Override validator to handle validating a given input value.
  @override
  ReservationDateError? validator(String value) {
    
    if (value.isEmpty) return ReservationDateError.empty;
    if (!reservationDayRegExp.hasMatch(value)) return ReservationDateError.format;

    // Intenta convertir la cadena a DateTime para verificar su validez
    try {
      DateFormat format = DateFormat('yyyy-MM-dd');
      DateTime parsedDate = format.parseStrict(value);
      // Verifica si la fecha es futura
      if (!parsedDate.isAfter(DateTime.now())) {
        return ReservationDateError.futureDate;
      }
    } catch (_) {
      return ReservationDateError.format; // Retorna un error si la conversión falla
    }

    return null;
  }
}
