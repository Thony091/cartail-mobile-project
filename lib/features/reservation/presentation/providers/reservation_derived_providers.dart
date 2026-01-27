import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation.dart';
import 'reservation_provider.dart';

/// Creates a Map of reservations by ID for efficient lookup.
/// Follows the same pattern as usersByIdProvider in the users_provider.
final reservationsByIdProvider = Provider<Map<String, Reservation>>((ref) {
  final state = ref.watch(reservationProvider);
  return {
    for (final reservation in state.reservations)
      reservation.id: reservation,
  };
});
