import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ticket.dart';
import 'tickets_repository_provider.dart';

/// Obtiene tickets asignados a un operario.
final getTicketsByOperatorProvider =
    FutureProvider.family<List<Ticket>, String>((ref, operatorId) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  final tickets = await repository.getTickets();
  return tickets.where((ticket) => ticket.idUser == operatorId).toList();
});

/// Obtiene tickets asociados a una reserva.
final getTicketByReservationProvider =
    FutureProvider.family<List<Ticket>, String>((ref, reservationId) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  final tickets = await repository.getTickets();
  return tickets.where((ticket) => ticket.idReserva == reservationId).toList();
});

/// Actualiza el estado de un ticket.
final updateTicketStatusProvider =
    FutureProvider.family<Ticket, TicketStatusUpdateInput>((ref, input) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  return repository.createUpdateTicket({
    'id': input.ticketId,
    'idEstado': input.status,
  });
});

/// Agrega un comentario a un ticket.
final addTicketCommentProvider =
    FutureProvider.family<Ticket, TicketCommentInput>((ref, input) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  return repository.createUpdateTicket({
    'id': input.ticketId,
    'comentario': input.message,
  });
});

class TicketStatusUpdateInput {
  final String ticketId;
  final dynamic status;

  const TicketStatusUpdateInput({
    required this.ticketId,
    required this.status,
  });
}

class TicketCommentInput {
  final String ticketId;
  final String message;

  const TicketCommentInput({
    required this.ticketId,
    required this.message,
  });
}
