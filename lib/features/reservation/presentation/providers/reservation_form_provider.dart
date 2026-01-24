import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';


import '../../../../presentation/presentation_container.dart';
import '../../../auth/presentation/providers/better_auth_provider.dart';

final reservationFormProvider = StateNotifierProvider.autoDispose<ReservationFormNotifier, ReservationFormState>((ref) {
  final createReservationCallback = ref.watch(reservationProvider.notifier).createReservation;

  return ReservationFormNotifier(
    createReservationCallback: createReservationCallback,
    ref: ref,
  );
});

class ReservationFormNotifier extends StateNotifier<ReservationFormState>{

  final Future<bool> Function( Map<String, dynamic> reservationSimilar ) createReservationCallback;
  final Ref ref;

  ReservationFormNotifier({
    required this.createReservationCallback,
    required this.ref,
  }): super( ReservationFormState() );

  onVehiclePlateChange( String value ) {
    final newPlate = Name.dirty(value);
    state = state.copyWith(
      vehiclePlate: newPlate,
      isValid: Formz.validate([ newPlate, state.vehiclePlate ])
    );
  }

  onClientNameChange( String value ) {
    final newName = Name.dirty(value);
    state = state.copyWith(
      clientName: newName,
      isValid: Formz.validate([ newName, state.clientName ])
    );
  }

  onClientEmailChange( String value ) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      clientEmail: newEmail,
      isValid: Formz.validate([ newEmail, state.clientEmail ])
    );
  }

  onClientPhoneChange( String value ) {
    final newPhone = Phone.dirty(value);
    state = state.copyWith(
      clientPhone: newPhone,
      isValid: Formz.validate([ newPhone, state.clientPhone ])
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
    state = state.copyWith(
      time: newTime,
      isValid: Formz.validate([newTime, state.time])
    );
  }

  onEndTimeEstimatedChange( String value) {
    state = state.copyWith(
      endTimeEstimated: value
    );
  }

  onCustomerNotesChange( String value ) {
    state = state.copyWith(
      customerNotes: value
    );
  }

  onReminderChange( bool value ) {
    state = state.copyWith(
      reminder: value
    );
  }

  onServiceIdChange( String value ) {
    state = state.copyWith(
      serviceId: value
    );
  }

  Future<bool> onFormSubmit() async {

    try {

      _touchEveryField();
      
      if ( !state.isValid || state.serviceId.isEmpty ) return false;

      state = state.copyWith( isPosting: true );

      final clientId = await _ensureClientId();
      if (clientId == null) return false;

      final reservationSimilar = {
        'patenteVehiculo': state.vehiclePlate.value,
        'fecha': state.date.value,
        'horaInicio': state.time.value,
        'horaFinEstimada': state.endTimeEstimated,
        'notasCliente': state.customerNotes,
        'notasMecanico': '',
        'recordatorio': state.reminder,
        'idEstado': state.statusId,
        'idServicio': int.tryParse(state.serviceId) ?? state.statusId,
        'idCliente': clientId,
      };
      reservationSimilar.removeWhere(
        (key, value) => value == null || (value is String && value.trim().isEmpty),
      );

      final created = await createReservationCallback(reservationSimilar);

      state = state.copyWith( isPosting: false );

      return created;

    } catch (e) {
      return false;
    }

  }

  Future<int?> _ensureClientId() async {
    if (state.clientId != null) {
      return state.clientId;
    }

    final userData = ref.read(betterAuthProvider).user;
    final clientRepository = ref.read(clientRepositoryProvider);

    final name = (userData?.name?.isNotEmpty ?? false)
        ? userData!.name!
        : state.clientName.value;
    final email = (userData?.email.isNotEmpty ?? false)
        ? userData!.email
        : state.clientEmail.value;
    final phone = (userData?.phone?.isNotEmpty ?? false)
        ? userData!.phone!
        : state.clientPhone.value;

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      return null;
    }

    final existing = await clientRepository.findClientByEmailOrPhone(
      email: email,
      phone: phone,
    );
    if (existing != null) {
      state = state.copyWith(clientId: existing.id);
      return existing.id;
    }

    final client = await clientRepository.createUpdateClient({
      'nombre': name,
      'email': email,
      'telefono': phone,
    });

    state = state.copyWith(clientId: client.id);
    return client.id;
  }

  void _touchEveryField() {
    final authState = ref.read(betterAuthProvider);
    final isAuthenticated = authState.isAuthenticated;
    final userData = authState.user;
    final needsClientInfo = !isAuthenticated ||
        userData == null ||
        (userData.name?.isEmpty ?? true) ||
        userData.email.isEmpty ||
        (userData.phone?.isEmpty ?? true);

    final validationInputs = <FormzInput>[
      Name.dirty(state.vehiclePlate.value),
      ReservationDate.dirty(state.date.value),
      ReservationTime.dirty(state.time.value),
    ];

    if (needsClientInfo) {
      validationInputs.addAll([
        Name.dirty(state.clientName.value),
        Email.dirty(state.clientEmail.value),
        Phone.dirty(state.clientPhone.value),
      ]);
    }

    state = state.copyWith(
      vehiclePlate: Name.dirty(state.vehiclePlate.value),
      date: ReservationDate.dirty(state.date.value),
      time: ReservationTime.dirty(state.time.value),
      clientName: Name.dirty(state.clientName.value),
      clientEmail: Email.dirty(state.clientEmail.value),
      clientPhone: Phone.dirty(state.clientPhone.value),
      isValid: Formz.validate(validationInputs)
    );
  }

  void resetForm() {
    state = ReservationFormState();
  }


}

class ReservationFormState {

  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Name vehiclePlate;
  final ReservationDate date;
  final ReservationTime time;
  final String endTimeEstimated;
  final String customerNotes;
  final bool reminder;
  final int statusId;
  final int? clientId;
  final String serviceId;
  final Name clientName;
  final Email clientEmail;
  final Phone clientPhone;
  final List<String> timeOptions;

  ReservationFormState({
    this.isPosting      = false,
    this.isFormPosted   = false,
    this.isValid        = false,
    this.vehiclePlate   = const Name.pure(),
    this.date           = minValidDate,
    this.time           = minValidTime,
    this.endTimeEstimated = '',
    this.customerNotes  = '',
    this.reminder       = true,
    this.statusId       = 1,
    this.clientId,
    this.serviceId      = '',
    this.clientName     = const Name.pure(),
    this.clientEmail    = const Email.pure(),
    this.clientPhone    = const Phone.pure(),
    this.timeOptions    = const []
  });

  ReservationFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Name? vehiclePlate,
    ReservationDate? date,
    ReservationTime? time,
    String? endTimeEstimated,
    String? customerNotes,
    bool? reminder,
    int? statusId,
    int? clientId,
    String? serviceId,
    Name? clientName,
    Email? clientEmail,
    Phone? clientPhone,
    List<String>? timeOptions,
  }) => ReservationFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    vehiclePlate: vehiclePlate ?? this.vehiclePlate,
    date: date ?? this.date,
    time: time ?? this.time,
    endTimeEstimated: endTimeEstimated ?? this.endTimeEstimated,
    customerNotes: customerNotes ?? this.customerNotes,
    reminder: reminder ?? this.reminder,
    statusId: statusId ?? this.statusId,
    clientId: clientId ?? this.clientId,
    serviceId: serviceId ?? this.serviceId,
    clientName: clientName ?? this.clientName,
    clientEmail: clientEmail ?? this.clientEmail,
    clientPhone: clientPhone ?? this.clientPhone,
    timeOptions: timeOptions ?? this.timeOptions,
  );

  @override
  String toString() {
    return '''
      ReservationFormState:
        isPosting: $isPosting
        isFormPosted: $isFormPosted
        isValid: $isValid
        vehiclePlate: $vehiclePlate
        date: $date
        time: $time
        endTimeEstimated: $endTimeEstimated
        customerNotes: $customerNotes
        reminder: $reminder
        statusId: $statusId
        clientId: $clientId
        serviceId: $serviceId
        clientName: $clientName
        clientEmail: $clientEmail
        clientPhone: $clientPhone
        timeOptions: $timeOptions
      ''';
  }

}
const ReservationDate minValidDate = ReservationDate.dirty('01-01-2000');
const ReservationTime minValidTime = ReservationTime.dirty('00:00');
