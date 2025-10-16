import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';


import '../../presentation_container.dart';

final reservationFormProvider = StateNotifierProvider.autoDispose<ReservationFormNotifier, ReservationFormState>    ((ref) {

  final createReservationCallback = ref.watch( reservationProvider.notifier ).createReservation;

  return ReservationFormNotifier(
    createReservationCallback: createReservationCallback
  );
});

class ReservationFormNotifier extends StateNotifier<ReservationFormState>{

  final Function( String, String, String, String, String, String ) createReservationCallback;

  ReservationFormNotifier({
    required this.createReservationCallback,
  }): super( ReservationFormState() );

  onNameChange( String value ) {
    final newName = Name.dirty(value);
    state = state.copyWith(
      name: newName,
      isValid: Formz.validate([ newName, state.name ])
    );
  }

  onEmailChange( String value ) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([ newEmail, state.email ])
    );
  }

  onReservationDate( DateTime value ) {
    final newDate = ReservationDate.dirty(DateFormat('yyyy-MM-dd').format(value));    
    state = state.copyWith(
      date: newDate,
      isValid: Formz.validate([newDate, state.date])
    );
  }

  onReservationTime( String value) {
    final newTime = ReservationTime.dirty(value.toString());
    // final newTime = ReservationTime.dirty(value.toString());
    state = state.copyWith(
      time: newTime,
      isValid: Formz.validate([newTime, state.time])
    );
  }

  onRutChange( String value ) {
    final newRut = Rut.dirty(value);
    state = state.copyWith(
      rut: newRut,
      isValid: Formz.validate([ newRut, state.rut ])
    );
  }

  onServiceNameChange( String value ) {
    state = state.copyWith(
      serviceName: value
    );
  }

  Future<bool> createReservation() async {

    try {

      _touchEveryField();
      
      if ( !state.isValid ) return false;

      state = state.copyWith( isPosting: true );

      /// Convertir la fecha y la hora a strings antes de enviarlas
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(state.date.value)).toString();
      String formattedTime = state.time.value;
      
      await createReservationCallback(
        state.name.value,
        state.email.value,
        state.rut.value,
        formattedDate,
        formattedTime,
        state.serviceName
      );

      state = state.copyWith( isPosting: false );

      return true;

    } catch (e) {
      return false;
    }

  }

  void _touchEveryField() {
    state = state.copyWith(
      name: Name.dirty(state.name.value),
      email: Email.dirty(state.email.value),
      rut: Rut.dirty(state.rut.value),
      date: ReservationDate.dirty(state.date.value),
      time: ReservationTime.dirty(state.time.value),
      serviceName: state.serviceName,
      isValid: Formz.validate([
        Name.dirty(state.name.value),
        Email.dirty(state.email.value),
        Rut.dirty(state.rut.value),
        ReservationDate.dirty(state.date.value),
        ReservationTime.dirty(state.time.value),
      ])
    );
  }


}

class ReservationFormState {

  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Name name;
  final Email email;
  final Rut rut;
  final ReservationDate date;
  final ReservationTime time;
  final String serviceName;
  final List<String> timeOptions;

  ReservationFormState({
    this.isPosting      = false,
    this.isFormPosted   = false,
    this.isValid        = false,
    this.name           = const Name.pure(),
    this.email          = const Email.pure(),
    this.rut            = const Rut.pure(),
    this.date           = minValidDate,
    this.time           = minValidTime,
    this.serviceName    = '',
    this.timeOptions    = const []
  });

  ReservationFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Name? name,
    Email? email,
    Rut? rut,
    ReservationDate? date,
    ReservationTime? time,
    String? serviceName,
    List<String>? timeOptions,
  }) => ReservationFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    name: name ?? this.name,
    email: email ?? this.email,
    rut: rut ?? this.rut,
    date: date ?? this.date,
    time: time ?? this.time,
    serviceName: serviceName ?? this.serviceName,
    timeOptions: timeOptions ?? this.timeOptions,
  );

  @override
  String toString() {
    return '''
      ReservationFormState:
        isPosting: $isPosting
        isFormPosted: $isFormPosted
        isValid: $isValid
        name: $name
        email: $email
        rut: $rut
        date: $date
        time: $time
        serviceName: $serviceName
        timeOptions: $timeOptions
      ''';
  }

}
const ReservationDate minValidDate = ReservationDate.dirty('01-01-2000'); // Asumiendo un formato válido
const ReservationTime minValidTime = ReservationTime.dirty('00:00'); // Asumiendo un formato válido
