import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';

import '../../../../config/services/error_handler_service.dart';
import '../../../../presentation/presentation_container.dart';
import '../../../auth/presentation/providers/better_auth_provider.dart';
import '../../../slot/domain/entities/slot.dart';
import '../../../slot/presentation/providers/slot_repository_provider.dart';
// import '../../../ticket/presentation/providers/tickets_provider.dart';

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

  Future<bool> onFormSubmit() async {
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
        return false;
      }

      state = state.copyWith( isPosting: true );

      final clientId = await _ensureClientId();
      if (clientId == null) return false;

      final slotRepository = ref.read(slotRepositoryProvider);
      final slot = await slotRepository.getSlotById(state.selectedSlotId!);
      if (!slot.isAvailable) {
        state = state.copyWith(
          isPosting: false,
          slotErrorMessage: 'El horario seleccionado ya no está disponible.',
          clearSelectedSlotId: true,
        );
        await _loadAvailableSlots(force: true);
        return false;
      }

      final reservationSimilar = {
        'patenteVehiculo': state.vehiclePlate.value,
        'notasCliente': state.customerNotes.value,
        'recordatorio': state.reminder,
        'idEstado': state.statusId,
        'idServicio': int.tryParse(state.serviceId) ?? state.statusId,
        'idCliente': clientId,
        'idSlot': slot.id,
      };

      final created = await createReservationCallback(reservationSimilar);
      if (created) {
        await ref.read(ticketsProvider.notifier).getTickets();
      }

      state = state.copyWith( isPosting: false );

      return created;

    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: ErrorHandlerService.readableError(e),
      );
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
      ReservationDate.dirty(state.date.value),
      ReservationTime.dirty(state.time.value),
      ReservationTime.dirty(state.endTimeEstimated.value),
      Messages.dirty(state.customerNotes.value),
      Messages.dirty(state.mechanicNotes.value),
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
    if (state.serviceId.isEmpty || state.date.value.isEmpty || !state.date.isValid) {
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
      final slots = await slotRepository.getSlots();
      final dateKey = state.date.value.substring(0, 10);
      final available = slots
          .where(
            (slot) =>
                slot.serviceId == serviceId &&
                slot.isAvailable &&
                slot.date.startsWith(dateKey),
          )
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

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
