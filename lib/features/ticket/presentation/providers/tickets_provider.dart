import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../../../presentation/presentation_container.dart';
import '../../data/mappers/ticket_mapper.dart';

final ticketsProvider = StateNotifierProvider<TicketsNotifier, TicketsState>((ref) {
  final ticketRepository = ref.watch(ticketsRepositoryProvider);
  return TicketsNotifier(ticketRepository: ticketRepository);
});

class TicketsNotifier extends StateNotifier<TicketsState> {
  final TicketRepository ticketRepository;

  TicketsNotifier({required this.ticketRepository}) : super(TicketsState()) {
    getTickets();
  }

  Future<void> getTickets() async {
    state = state.copyWith(isLoading: true, error: '');

    try {
      final tickets = await ticketRepository.getTickets();
      state = state.copyWith(tickets: tickets, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al obtener los tickets',
      );
    }
  }

  Future<void> deleteTicket(String id) async {
    try {
      await ticketRepository.deleteTicket(id);
      state = state.copyWith(
        tickets: state.tickets.where((ticket) => ticket.id != id).toList(),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<bool> createOrUpdateTicket(Map<String, dynamic> ticketSimilar) async {
    try {
      final ticket = await ticketRepository.createUpdateTicket(ticketSimilar);
      final isInList = state.tickets.any((element) => element.id == ticket.id);

      if (!isInList) {
        state = state.copyWith(tickets: [...state.tickets, ticket]);
        return true;
      }

      state = state.copyWith(
        tickets: state.tickets
            .map((element) => (element.id == ticket.id) ? ticket : element)
            .toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTicket(Ticket ticket) async {
    final payload = _buildTicketPayload(ticket);
    return createOrUpdateTicket(payload);
  }

  Future<bool> assignOperator({
    required Ticket ticket,
    required String operatorId,
    required String operatorName,
  }) async {
    final stateId = ticket.stateId == null || ticket.stateId == 1 ? 2 : ticket.stateId;
    final payload = _buildTicketPayload(
      ticket.copyWith(
        assignedToId: operatorId,
        assignedToName: operatorName,
        stateId: stateId,
      ),
    );
    return createOrUpdateTicket(payload);
  }

  Future<bool> updateTicketStatus({
    required Ticket ticket,
    required int stateId,
  }) async {
    final payload = _buildTicketPayload(ticket.copyWith(stateId: stateId));
    return createOrUpdateTicket(payload);
  }

  Future<bool> addTicketComment({
    required Ticket ticket,
    required String comment,
    required String authorId,
    required String authorName,
  }) async {
    final now = DateTime.now().toIso8601String();
    final existing = ticket.metadata['comments'];
    final List<Map<String, dynamic>> comments = [];
    if (existing is List) {
      for (final item in existing) {
        if (item is Map<String, dynamic>) {
          comments.add(Map<String, dynamic>.from(item));
        }
      }
    }
    comments.add({
      'message': comment,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': now,
    });
    final updatedTicket = ticket.copyWith(
      metadata: {
        ...ticket.metadata,
        'comments': comments,
      },
    );
    return updateTicket(updatedTicket);
  }

  Map<String, dynamic> _buildTicketPayload(Ticket ticket) {
    final now = DateTime.now();
    final fallbackDate =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final normalized = ticket.copyWith(
      startDate: ticket.startDate.isNotEmpty ? ticket.startDate : fallbackDate,
      endDate: ticket.endDate.isNotEmpty ? ticket.endDate : fallbackDate,
      serviceId: ticket.serviceId ?? 1,
      stateId: ticket.stateId ?? 1,
      importanceId: ticket.importanceId ?? 1,
      urgencyId: ticket.urgencyId ?? 1,
    );
    final payload = TicketMapper.entityToJson(normalized);
    payload['id'] = ticket.id;
    return payload;
  }
}

class TicketsState {
  final List<Ticket> tickets;
  final bool isLoading;
  final String error;

  TicketsState({
    this.tickets = const [],
    this.isLoading = true,
    this.error = '',
  });

  TicketsState copyWith({
    List<Ticket>? tickets,
    bool? isLoading,
    String? error,
  }) => TicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
}
