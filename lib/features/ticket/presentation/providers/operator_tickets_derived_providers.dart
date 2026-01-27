import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/data/models/admin_response_models.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/auth/presentation/providers/users_provider.dart';
import 'package:portafolio_project/features/client/domain/entities/client.dart';
import 'package:portafolio_project/features/client/presentation/providers/clients_provider.dart';
import 'package:portafolio_project/features/reservation/domain/entities/reservation.dart';
import 'package:portafolio_project/features/reservation/presentation/providers/reservation_derived_providers.dart';

import '../../domain/entities/ticket.dart';
import 'tickets_provider.dart';

// ============================================================================
// PROVIDER 1: Tickets asignados al operario actual
// ============================================================================

/// Filtra tickets asignados al operario logueado
/// Elimina el need de calcular assignedTickets en el widget padre
final operatorAssignedTicketsProvider = Provider<List<Ticket>>((ref) {
  final ticketsState = ref.watch(ticketsProvider);
  final authState = ref.watch(betterAuthProvider);

  if (authState.session == null) return [];

  final operatorId = authState.session!.user.id;
  return ticketsState.tickets
      .where((ticket) => ticket.idUser == operatorId)
      .toList();
});

// ============================================================================
// PROVIDER 2: Tickets filtrados (por estado y búsqueda)
// ============================================================================

/// Aplica filtros de estado y búsqueda sobre tickets asignados
final filteredOperatorTicketsProvider = Provider<List<Ticket>>((ref) {
  final assignedTickets = ref.watch(operatorAssignedTicketsProvider);
  final filtersState = ref.watch(ticketsFiltersProvider);
  final usersById = ref.watch(usersByIdProvider);
  final clientsState = ref.watch(clientsProvider);
  final reservationsById = ref.watch(reservationsByIdProvider);

  // Crear mapa de clientes
  final clientsById = <String, Client>{
    for (final client in clientsState.clients) client.id.toString(): client,
  };

  return assignedTickets.where((ticket) {
    // Filtrar por estado
    final stateId = ticket.estado.id;
    final matchesStatus = switch (filtersState.filterStatus) {
      'pending' => stateId == 1 || stateId == 2,
      'inProgress' => stateId == 3,
      'completed' => stateId == 4 || stateId == 5,
      _ => true,
    };

    // Filtrar por búsqueda
    final query = filtersState.searchQuery.trim().toLowerCase();
    if (query.isEmpty) return matchesStatus;

    final clientName = _resolveClientName(ticket, usersById, clientsById, reservationsById);
    final matchesSearch = ticket.id.toString().contains(query) ||
        clientName.toLowerCase().contains(query) ||
        ticket.nombre.toLowerCase().contains(query) ||
        ticket.description.toLowerCase().contains(query);

    return matchesStatus && matchesSearch;
  }).toList();
});

// ============================================================================
// PROVIDER 3: Estadísticas de tickets
// ============================================================================

class OperatorTicketStats {
  final int pending;
  final int inProgress;
  final int completed;

  const OperatorTicketStats({
    required this.pending,
    required this.inProgress,
    required this.completed,
  });
}

/// Calcula estadísticas de tickets filtrados
final operatorTicketStatsProvider = Provider<OperatorTicketStats>((ref) {
  final tickets = ref.watch(filteredOperatorTicketsProvider);

  int pending = 0;
  int inProgress = 0;
  int completed = 0;

  for (final ticket in tickets) {
    final stateId = ticket.estado.id;
    if (stateId == 1 || stateId == 2) {
      pending++;
    } else if (stateId == 3) {
      inProgress++;
    } else if (stateId == 4 || stateId == 5) {
      completed++;
    }
  }

  return OperatorTicketStats(
    pending: pending,
    inProgress: inProgress,
    completed: completed,
  );
});

// ============================================================================
// PROVIDER 4: Nombre del operario actual
// ============================================================================

/// Obtiene el nombre display del operario actual
final currentOperatorNameProvider = Provider<String>((ref) {
  final authState = ref.watch(betterAuthProvider);

  if (authState.session == null) return 'Usuario no autenticado';

  final name = authState.session!.user.name?.trim();
  if (name != null && name.isNotEmpty) return name;
  return authState.session!.user.email;
});

// ============================================================================
// PROVIDER 5: ID del operario actual
// ============================================================================

/// Obtiene el ID del operario actual
final currentOperatorIdProvider = Provider<String>((ref) {
  final authState = ref.watch(betterAuthProvider);
  return authState.session?.user.id ?? '';
});

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

String _resolveClientName(
  Ticket ticket,
  Map<String, AdminUserModel> usersById,
  Map<String, Client> clientsById,
  Map<String, Reservation> reservationsById,
) {
  final explicit = ticket.nombre.trim();
  if (explicit.isNotEmpty) return explicit;

  final reservation = reservationsById[ticket.idReserva];
  if (reservation != null) {
    final name = reservation.name?.toString().trim() ?? '';
    if (name.isNotEmpty) return name;
    final email = reservation.email?.toString().trim() ?? '';
    if (email.isNotEmpty) return email;
  }

  final userId = ticket.idUser?.trim() ?? '';
  if (userId.isEmpty) return 'Sin nombre';
  final client = clientsById[userId];
  if (client != null) {
    final name = client.name.trim();
    if (name.isNotEmpty) return name;
    if (client.email.trim().isNotEmpty) return client.email.trim();
  }

  final user = usersById[userId];
  if (user == null) return 'Cliente no encontrado';

  final name = user.name?.trim();
  if (name != null && name.isNotEmpty) return name;
  return user.email;
}
