import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_payment_init.dart';
import 'reservation_repository_provider.dart';

/// Inicia el pago de una reserva y devuelve la URL de pago.
final iniciarPagoReservaProvider =
    FutureProvider.family<ReservationPaymentInit, ReservationPaymentInitPayload>(
        (ref, payload) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return repository.iniciarPagoReserva(payload.data);
});

/// Confirma localmente una reserva ya pagada (solo cache local).
final confirmarReservaPagadaProvider =
    FutureProvider.family<void, ReservationPaidConfirmationInput>(
        (ref, input) async {
  final repository = ref.watch(reservationRepositoryProvider);
  await repository.guardarReservaConfirmadaLocal(input.reservation);
});

class ReservationPaymentInitPayload {
  final Map<String, dynamic> data;

  const ReservationPaymentInitPayload(this.data);
}

class ReservationPaidConfirmationInput {
  final Reservation reservation;

  const ReservationPaidConfirmationInput({required this.reservation});
}
