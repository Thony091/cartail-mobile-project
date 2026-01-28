import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/client/presentation/providers/clients_provider.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
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

/// Enriquece las reservas con datos del cliente desde el API
/// Combina datos de reservacion con información del cliente
final enrichedReservationsProvider = Provider<List<Reservation>>((ref) {
  final reservationState = ref.watch(reservationProvider);
  final reservations = reservationState.reservations;

  // Obtener todos los clientes disponibles
  final clientsState = ref.watch(clientsProvider);
  final clients = clientsState.clients;

  // Crear un mapa de clientes para búsqueda O(1)
  final clientsById = {for (final client in clients) client.id: client};

  print('\n🔄 enrichedReservationsProvider:');
  print('   📋 Total reservas: ${reservations.length}');
  print('   👥 Total clientes: ${clients.length}');

  // Enriquecer cada reserva con datos del cliente
  return reservations.map((reservation) {
    final clientId = reservation.clientId;
    if (clientId != null && clientsById.containsKey(clientId)) {
      final client = clientsById[clientId]!;

      // Si el nombre está vacío en la reserva, usar del cliente
      final name = reservation.name.isEmpty ? client.name : reservation.name;
      final email = reservation.email.isEmpty ? client.email : reservation.email;

      print('   ✅ Reserva ${reservation.id}: enriquecida con cliente ${clientId} -> email: $email');

      return Reservation(
        id: reservation.id,
        name: name,
        rut: reservation.rut,
        email: email,
        reservationDate: reservation.reservationDate,
        reservationTime: reservation.reservationTime,
        serviceName: reservation.serviceName,
        vehiclePlate: reservation.vehiclePlate,
        endTimeEstimated: reservation.endTimeEstimated,
        customerNotes: reservation.customerNotes,
        mechanicNotes: reservation.mechanicNotes,
        idTransaccion: reservation.idTransaccion,
        reminder: reservation.reminder,
        statusId: reservation.statusId,
        serviceId: reservation.serviceId,
        clientId: reservation.clientId,
        slotId: reservation.slotId,
      );
    }
    // Si no tiene cliente ID o no se encuentra, devolver tal cual
    print('   ❌ Reserva ${reservation.id}: NO enriquecida (clientId=$clientId, clientes=${clients.length})');
    return reservation;
  }).toList();
});

/// Crea un Map de reservas enriquecidas por ID
/// Para uso en filtrado de servicios del usuario
final enrichedReservationsByIdProvider = Provider<Map<String, Reservation>>((ref) {
  final enriched = ref.watch(enrichedReservationsProvider);
  return {
    for (final reservation in enriched)
      reservation.id: reservation,
  };
});

/// Obtiene las reservas del usuario autenticado (filtrando por email)
/// Retorna una lista de reservas que pertenecen al usuario actual
final userReservationsProvider = Provider<List<Reservation>>((ref) {
  final authState = ref.watch(betterAuthProvider);
  final userEmail = authState.session?.user.email;
  final enrichedReservations = ref.watch(enrichedReservationsProvider);

  if (userEmail == null || userEmail.trim().isEmpty) {
    print('❌ userReservationsProvider: No user email');
    return [];
  }

  final normalizedUserEmail = userEmail.toLowerCase().trim();
  final userReservations = enrichedReservations
      .where((res) => res.email.toLowerCase().trim() == normalizedUserEmail)
      .toList();

  print('\n👤 userReservationsProvider:');
  print('   🔍 Buscando reservas para: $userEmail');
  print('   ✅ Encontradas ${userReservations.length} reservas');
  for (var res in userReservations) {
    print('      - Reserva ${res.id}: ${res.serviceName}');
  }

  return userReservations;
});

/// Obtiene los IDs de reservas del usuario actual
/// Útil para filtrar tickets que pertenecen al usuario
final userReservationIdsProvider = Provider<Set<String>>((ref) {
  final userReservations = ref.watch(userReservationsProvider);
  return userReservations.map((res) => res.id).toSet();
});
