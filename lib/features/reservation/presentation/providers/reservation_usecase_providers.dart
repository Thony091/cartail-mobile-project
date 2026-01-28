import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reservation.dart';
import 'reservation_repository_provider.dart';

/// Obtiene reservas asociadas a un usuario.
final getReservationsByUserProvider =
    FutureProvider.family<List<Reservation>, String>((ref, userId) async {
  final repository = ref.watch(reservationRepositoryProvider);
  final reservations = await repository.getReservations();
  return reservations.where((reservation) {
    final clientId = reservation.clientId?.toString();
    return clientId == userId || reservation.email == userId;
  }).toList();
});

/// Crea una reserva a partir de un slot.
final createReservationFromSlotProvider =
    FutureProvider.family<Reservation, String>((ref, slotId) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return repository.createUpdateReservation({
    'idSlot': slotId,
  });
});

/// Cancela una reserva existente.
final cancelReservationProvider =
    FutureProvider.family<void, String>((ref, reservationId) async {
  final repository = ref.watch(reservationRepositoryProvider);
  await repository.deleteReservation(reservationId);
});
