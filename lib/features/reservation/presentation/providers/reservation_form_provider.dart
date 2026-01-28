import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';

import '../../../../config/services/error_handler_service.dart';
import '../../../../presentation/presentation_container.dart';
import '../../../auth/presentation/providers/better_auth_provider.dart';
import '../../domain/entities/reservation.dart';
import '../../../slot/domain/entities/slot.dart';
import '../../../slot/presentation/providers/slot_repository_provider.dart';
import '../models/reservation_payment_session.dart';
import 'reservation_payment_usecase_providers.dart';

final reservationFormProvider = StateNotifierProvider.autoDispose<ReservationFormNotifier, ReservationFormState>((ref) {
  return ReservationFormNotifier(ref: ref);
});

class ReservationFormNotifier extends StateNotifier<ReservationFormState>{

  final Ref ref;

  ReservationFormNotifier({
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
      isValid: Formz.validate([newDate, state.date]),
      clearSelectedSlotId: true,
      time: const ReservationTime.pure(),
      endTimeEstimated: const ReservationTime.pure(),
      slotErrorMessage: null,
    );
    _loadAvailableSlots();
  }

  onReservationTime( String value) {
    final newTime = ReservationTime.dirty(value.toString());
    state = state.copyWith(
      time: newTime,
      isValid: Formz.validate([newTime, state.time])
    );
  }

  onEndTimeEstimatedChange( String value) {
    final newEndTime = ReservationTime.dirty(value.toString());
    state = state.copyWith(
      endTimeEstimated: newEndTime,
      isValid: Formz.validate([newEndTime, state.endTimeEstimated])
    );
  }

  onCustomerNotesChange( String value ) {
    final newNotes = Messages.dirty(value);
    state = state.copyWith(
      customerNotes: newNotes,
      isValid: Formz.validate([newNotes, state.customerNotes])
    );
  }

  onMechanicNotesChange( String value ) {
    final newNotes = Messages.dirty(value);
    state = state.copyWith(
      mechanicNotes: newNotes,
      isValid: Formz.validate([newNotes, state.mechanicNotes])
    );
  }

  onReminderChange( bool value ) {
    state = state.copyWith(
      reminder: value
    );
  }

  void onImportanceChange(int? value) {
    state = state.copyWith(importanceId: value);
  }

  void onUrgencyChange(int? value) {
    state = state.copyWith(urgencyId: value);
  }

  onServiceIdChange( String value ) {
    state = state.copyWith(
      serviceId: value,
      clearSelectedSlotId: true,
      time: const ReservationTime.pure(),
      endTimeEstimated: const ReservationTime.pure(),
      slotErrorMessage: null,
    );
    _loadAvailableSlots();
  }

  void onSlotSelected(Slot slot) {
    state = state.copyWith(
      selectedSlotId: slot.id,
      time: ReservationTime.dirty(_normalizeSlotTime(slot.startTime)),
      endTimeEstimated: ReservationTime.dirty(_normalizeSlotTime(slot.endTime)),
      slotErrorMessage: null,
    );
  }

  Future<ReservationPaymentSession?> onFormSubmit() async {
    // Limpiar error previo
    state = state.copyWith(errorMessage: '');

    try {

      state = state.copyWith(isFormPosted: true);
      _touchEveryField();

      if ( !state.isValid || state.serviceId.isEmpty || state.selectedSlotId == null ) {
        if (state.selectedSlotId == null) {
          state = state.copyWith(
            slotErrorMessage: 'Debes seleccionar un horario disponible',
          );
        }
        return null;
      }
      if (state.importanceId == null || state.urgencyId == null) {
        state = state.copyWith(
          errorMessage: 'Debes seleccionar importancia y urgencia',
        );
        return null;
      }

      state = state.copyWith( isPosting: true );

      final authState = ref.read(betterAuthProvider);
      final authUser = authState.user;
      final isAuthenticated = authState.isAuthenticated;

      String? userId;
      int? clientId;

      if (isAuthenticated && authUser != null) {
        userId = authUser.id;
        clientId = null;
      } else {
        userId = null;
        clientId = await _ensureClientId();
        if (clientId == null) {
          final userData = authUser;
          final needsClientInfo = userData == null ||
              (userData.name?.isEmpty ?? true) ||
              userData.email.isEmpty;

          final errorMsg = needsClientInfo
              ? 'Debes completar nombre y correo electrónico'
              : 'No se pudo crear el cliente';

          state = state.copyWith(
            isPosting: false,
            errorMessage: errorMsg,
          );
          return null;
        }
      }

      final slotRepository = ref.read(slotRepositoryProvider);
      final slot = await slotRepository.getSlotById(state.selectedSlotId!);
      if (!slot.isAvailable) {
        state = state.copyWith(
          isPosting: false,
          slotErrorMessage: 'El horario seleccionado ya no está disponible.',
          clearSelectedSlotId: true,
        );
        await _loadAvailableSlots(force: true);
        return null;
      }

      final reservationSimilar = {
        'patenteVehiculo': state.vehiclePlate.value,
        'notasCliente': state.customerNotes.value,
        'recordatorio': state.reminder,
        'idEstado': state.statusId,
        'idServicio': int.tryParse(state.serviceId) ?? state.statusId,
        'idImportancia': state.importanceId,
        'idUrgencia': state.urgencyId,
        'idCliente': clientId,
        'usuarioId': userId,
        'idSlot': slot.id,
      };

      // Inicia el pago en backend (no se crea reserva local antes de pagar).
      final paymentInit = await ref.read(
        iniciarPagoReservaProvider(ReservationPaymentInitPayload(reservationSimilar)).future,
      );

      state = state.copyWith( isPosting: false );

      final serviceName = _resolveServiceName(state.serviceId);
      final reservationId = paymentInit.reservationBackendId ??
          paymentInit.paymentId ??
          'paid-${DateTime.now().millisecondsSinceEpoch}';

      // Se prepara el borrador local para confirmar después del pago.
      return ReservationPaymentSession(
        paymentUrl: paymentInit.paymentUrl,
        reservation: Reservation(
          id: reservationId,
          name: _resolveClientName(),
          rut: '',
          email: _resolveClientEmail(),
          reservationDate: slot.date,
          reservationTime: slot.startTime,
          serviceName: serviceName,
          vehiclePlate: state.vehiclePlate.value,
          endTimeEstimated: slot.endTime,
          customerNotes: state.customerNotes.value,
          mechanicNotes: state.mechanicNotes.value,
          idTransaccion: '',
          reminder: state.reminder,
          statusId: state.statusId,
          serviceId: int.tryParse(state.serviceId),
          clientId: clientId,
          slotId: slot.id,
        ),
      );

    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: ErrorHandlerService.readableError(e),
      );
      return null;
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

    if (name.isEmpty || email.isEmpty) {
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

  String _normalizeSlotTime(String value) {
    if (value.isEmpty) return value;
    final parts = value.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return value;
  }

  String _resolveServiceName(String serviceId) {
    final servicesState = ref.read(servicesProvider);
    for (final service in servicesState.services) {
      if (service.id == serviceId) {
        return service.name;
      }
    }
    return serviceId;
  }

  String _resolveClientName() {
    final userData = ref.read(betterAuthProvider).user;
    return (userData?.name?.isNotEmpty ?? false)
        ? userData!.name!
        : state.clientName.value;
  }

  String _resolveClientEmail() {
    final userData = ref.read(betterAuthProvider).user;
    return (userData?.email.isNotEmpty ?? false)
        ? userData!.email
        : state.clientEmail.value;
  }

  void _touchEveryField() {
    final authState = ref.read(betterAuthProvider);
    final isAuthenticated = authState.isAuthenticated;
    final userData = authState.user;
    final needsClientInfo = !isAuthenticated ||
        userData == null ||
        (userData.name?.isEmpty ?? true) ||
        userData.email.isEmpty;

    final validationInputs = <FormzInput>[
      Name.dirty(state.vehiclePlate.value),
      Messages.dirty(state.customerNotes.value),
    ];

    if (needsClientInfo) {
      validationInputs.addAll([
        Name.dirty(state.clientName.value),
        Email.dirty(state.clientEmail.value),
      ]);
    }

    state = state.copyWith(
      vehiclePlate: Name.dirty(state.vehiclePlate.value),
      date: ReservationDate.dirty(state.date.value),
      time: ReservationTime.dirty(state.time.value),
      endTimeEstimated: ReservationTime.dirty(state.endTimeEstimated.value),
      customerNotes: Messages.dirty(state.customerNotes.value),
      mechanicNotes: Messages.dirty(state.mechanicNotes.value),
      clientName: Name.dirty(state.clientName.value),
      clientEmail: Email.dirty(state.clientEmail.value),
      clientPhone: Phone.dirty(state.clientPhone.value),
      isValid: Formz.validate(validationInputs)
    );
  }

  void resetForm() {
    state = ReservationFormState();
  }

  Future<void> _loadAvailableSlots({bool force = false}) async {
    if (state.serviceId.isEmpty) {
      return;
    }
    if (state.isLoadingSlots && !force) return;

    state = state.copyWith(isLoadingSlots: true, slotErrorMessage: null);
    try {
      final serviceId = int.tryParse(state.serviceId);
      if (serviceId == null) {
        state = state.copyWith(isLoadingSlots: false);
        return;
      }
      final slotRepository = ref.read(slotRepositoryProvider);
      final slots = await slotRepository
          .getSlots()
          .timeout(const Duration(seconds: 12));
      final available = slots
          .where(
            (slot) =>
                slot.isAvailable &&
                (slot.serviceId == serviceId || slot.serviceId == 0),
          )
          .toList()
        ..sort((a, b) {
          final dateCompare = a.date.compareTo(b.date);
          if (dateCompare != 0) return dateCompare;
          return a.startTime.compareTo(b.startTime);
        });

      final selected = state.selectedSlotId;
      final selectedExists =
          selected != null && available.any((slot) => slot.id == selected);

      state = state.copyWith(
        isLoadingSlots: false,
        availableSlots: available,
        selectedSlotId: selectedExists ? selected : null,
        clearSelectedSlotId: !selectedExists,
        time: selectedExists ? state.time : const ReservationTime.pure(),
        endTimeEstimated:
            selectedExists ? state.endTimeEstimated : const ReservationTime.pure(),
        timeOptions: available.map((slot) => slot.startTime).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSlots: false,
        slotErrorMessage: 'No se pudieron cargar los horarios.',
      );
    }
  }


}

class ReservationFormState {

  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Name vehiclePlate;
  final ReservationDate date;
  final ReservationTime time;
  final ReservationTime endTimeEstimated;
  final Messages customerNotes;
  final Messages mechanicNotes;
  final bool reminder;
  final int statusId;
  final int? clientId;
  final String serviceId;
  final int? importanceId;
  final int? urgencyId;
  final Name clientName;
  final Email clientEmail;
  final Phone clientPhone;
  final List<String> timeOptions;
  final String? errorMessage;
  final List<Slot> availableSlots;
  final int? selectedSlotId;
  final bool isLoadingSlots;
  final String? slotErrorMessage;

  ReservationFormState({
    this.isPosting      = false,
    this.isFormPosted   = false,
    this.isValid        = false,
    this.vehiclePlate   = const Name.pure(),
    this.date           = minValidDate,
    this.time           = minValidTime,
    this.endTimeEstimated = const ReservationTime.pure(),
    this.customerNotes  = const Messages.pure(),
    this.mechanicNotes  = const Messages.pure(),
    this.reminder       = true,
    this.statusId       = 1,
    this.clientId,
    this.serviceId      = '',
    this.importanceId,
    this.urgencyId,
    this.clientName     = const Name.pure(),
    this.clientEmail    = const Email.pure(),
    this.clientPhone    = const Phone.pure(),
    this.timeOptions    = const [],
    this.errorMessage,
    this.availableSlots = const [],
    this.selectedSlotId,
    this.isLoadingSlots = false,
    this.slotErrorMessage,
  });

  ReservationFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Name? vehiclePlate,
    ReservationDate? date,
    ReservationTime? time,
    ReservationTime? endTimeEstimated,
    Messages? customerNotes,
    Messages? mechanicNotes,
    bool? reminder,
    int? statusId,
    int? clientId,
    String? serviceId,
    int? importanceId,
    int? urgencyId,
    Name? clientName,
    Email? clientEmail,
    Phone? clientPhone,
    List<String>? timeOptions,
    String? errorMessage,
    List<Slot>? availableSlots,
    int? selectedSlotId,
    bool? isLoadingSlots,
    String? slotErrorMessage,
    bool clearSelectedSlotId = false,
  }) => ReservationFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    vehiclePlate: vehiclePlate ?? this.vehiclePlate,
    date: date ?? this.date,
    time: time ?? this.time,
    endTimeEstimated: endTimeEstimated ?? this.endTimeEstimated,
    customerNotes: customerNotes ?? this.customerNotes,
    mechanicNotes: mechanicNotes ?? this.mechanicNotes,
    reminder: reminder ?? this.reminder,
    statusId: statusId ?? this.statusId,
    clientId: clientId ?? this.clientId,
    serviceId: serviceId ?? this.serviceId,
    importanceId: importanceId ?? this.importanceId,
    urgencyId: urgencyId ?? this.urgencyId,
    clientName: clientName ?? this.clientName,
    clientEmail: clientEmail ?? this.clientEmail,
    clientPhone: clientPhone ?? this.clientPhone,
    timeOptions: timeOptions ?? this.timeOptions,
    errorMessage: errorMessage ?? this.errorMessage,
    availableSlots: availableSlots ?? this.availableSlots,
    selectedSlotId: clearSelectedSlotId ? null : (selectedSlotId ?? this.selectedSlotId),
    isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
    slotErrorMessage: slotErrorMessage ?? this.slotErrorMessage,
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
        mechanicNotes: $mechanicNotes
        reminder: $reminder
        statusId: $statusId
        clientId: $clientId
        serviceId: $serviceId
        importanceId: $importanceId
        urgencyId: $urgencyId
        clientName: $clientName
        clientEmail: $clientEmail
        clientPhone: $clientPhone
        timeOptions: $timeOptions
        errorMessage: $errorMessage
        availableSlots: ${availableSlots.length}
        selectedSlotId: $selectedSlotId
        isLoadingSlots: $isLoadingSlots
        slotErrorMessage: $slotErrorMessage
      ''';
  }

}
const ReservationDate minValidDate = ReservationDate.dirty('01-01-2000');
const ReservationTime minValidTime = ReservationTime.dirty('00:00');
