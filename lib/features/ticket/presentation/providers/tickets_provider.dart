import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../../../presentation/presentation_container.dart';
import '../../data/mappers/ticket_mapper.dart';
import '../../domain/entities/estado_ticket.dart';
import '../../domain/entities/importancia_ticket.dart';
import '../../domain/entities/urgencia_ticket.dart';

final ticketsProvider = StateNotifierProvider<TicketsNotifier, TicketsState>((ref) {
  final ticketRepository = ref.watch(ticketsRepositoryProvider);
  return TicketsNotifier(ticketRepository: ticketRepository);
});

final ticketsFiltersProvider =
    StateNotifierProvider<TicketsFiltersNotifier, TicketsFiltersState>((ref) {
  return TicketsFiltersNotifier();
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
        tickets: state.tickets.where((ticket) => ticket.id.toString() != id).toList(),
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
    final stateId = ticket.estado.id == 1 ? 2 : ticket.estado.id;
    final nextEstado = EstadoTicket(id: stateId, nombre: ticket.estado.nombre);
    final payload = _buildTicketPayload(
      ticket.copyWith(
        idUser: operatorId,
        estado: nextEstado,
      ),
    );
    return createOrUpdateTicket(payload);
  }

  Future<bool> updateTicketStatus({
    required Ticket ticket,
    required int stateId,
    String? stateName,
  }) async {
    final updated = ticket.copyWith(
      estado: EstadoTicket(
        id: stateId,
        nombre: stateName ?? ticket.estado.nombre,
      ),
    );
    _optimisticUpdate(updated);
    final payload = _buildTicketPayload(updated);
    return createOrUpdateTicket(payload);
  }

  Future<bool> updateTicketPriority({
    required Ticket ticket,
    int? importanceId,
    int? urgencyId,
    int? stateId,
    String? importanceName,
    String? urgencyName,
    String? stateName,
  }) async {
    final updated = ticket.copyWith(
      importancia: ImportanciaTicket(
        id: importanceId ?? ticket.importancia.id,
        nombre: importanceName ?? ticket.importancia.nombre,
      ),
      urgencia: UrgenciaTicket(
        id: urgencyId ?? ticket.urgencia.id,
        nombre: urgencyName ?? ticket.urgencia.nombre,
      ),
      estado: EstadoTicket(
        id: stateId ?? ticket.estado.id,
        nombre: stateName ?? ticket.estado.nombre,
      ),
    );
    _optimisticUpdate(updated);
    final payload = _buildTicketPayload(updated);
    return createOrUpdateTicket(payload);
  }

  Future<bool> addTicketComment({
    required Ticket ticket,
    required String comment,
    required String authorId,
    required String authorName,
  }) async {
    final trimmed = comment.trim();
    if (trimmed.isEmpty) return true;
    final updatedTicket = ticket.copyWith(
      description: ticket.description.isEmpty
          ? trimmed
          : '${ticket.description}\n\n$trimmed',
    );
    return updateTicket(updatedTicket);
  }

  Future<bool> updateTicketWithComments({
    required Ticket ticket,
    required int stateId,
    required List<String> comments,
    required String authorId,
    required String authorName,
  }) async {
    final updated = ticket.copyWith(
      estado: EstadoTicket(id: stateId, nombre: ticket.estado.nombre),
    );
    return updateTicket(updated);
  }

  Map<String, dynamic> _buildTicketPayload(Ticket ticket) {
    final now = DateTime.now();
    final fallbackDate = DateTime(now.year, now.month, now.day);
    final normalized = ticket.copyWith(
      desde: ticket.desde ?? fallbackDate,
      hasta: ticket.hasta ?? fallbackDate,
      idServicio: ticket.idServicio == 0 ? 1 : ticket.idServicio,
      estado: ticket.estado.id == 0
          ? EstadoTicket(id: 1, nombre: ticket.estado.nombre)
          : ticket.estado,
      importancia: ticket.importancia.id == 0
          ? ImportanciaTicket(id: 1, nombre: ticket.importancia.nombre)
          : ticket.importancia,
      urgencia: ticket.urgencia.id == 0
          ? UrgenciaTicket(id: 1, nombre: ticket.urgencia.nombre)
          : ticket.urgencia,
    );
    final payload = TicketMapper.entityToJson(normalized);
    payload['id'] = ticket.id;
    return payload;
  }

  void _optimisticUpdate(Ticket ticket) {
    final exists = state.tickets.any((item) => item.id == ticket.id);
    if (!exists) return;
    state = state.copyWith(
      tickets: state.tickets
          .map((item) => item.id == ticket.id ? ticket : item)
          .toList(),
    );
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

class TicketsFiltersNotifier extends StateNotifier<TicketsFiltersState> {
  Timer? _debounce;

  TicketsFiltersNotifier() : super(TicketsFiltersState());

  void startSearch() {
    state = state.copyWith(isSearching: true);
  }

  void stopSearch() {
    _debounce?.cancel();
    state = state.copyWith(isSearching: false, searchQuery: '');
  }

  void setSearchQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      state = state.copyWith(searchQuery: value);
    });
  }

  void setFilterStatus(String value) {
    state = state.copyWith(filterStatus: value);
  }

  void setFilterType(String value) {
    state = state.copyWith(filterType: value);
  }

  void setStateFilter(int? value) {
    state = state.copyWith(stateId: value);
  }

  void setImportanceFilter(int? value) {
    state = state.copyWith(importanceId: value);
  }

  void setUrgencyFilter(int? value) {
    state = state.copyWith(urgencyId: value);
  }

  void setServiceFilter(int? value) {
    state = state.copyWith(serviceId: value);
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class TicketsFiltersState {
  final String searchQuery;
  final String filterStatus;
  final String filterType;
  final bool isSearching;
  final int? stateId;
  final int? importanceId;
  final int? urgencyId;
  final int? serviceId;
  final DateTimeRange? dateRange;

  TicketsFiltersState({
    this.searchQuery = '',
    this.filterStatus = 'all',
    this.filterType = 'all',
    this.isSearching = false,
    this.stateId,
    this.importanceId,
    this.urgencyId,
    this.serviceId,
    this.dateRange,
  });

  TicketsFiltersState copyWith({
    String? searchQuery,
    String? filterStatus,
    String? filterType,
    bool? isSearching,
    int? stateId,
    int? importanceId,
    int? urgencyId,
    int? serviceId,
    DateTimeRange? dateRange,
  }) => TicketsFiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
      filterType: filterType ?? this.filterType,
      isSearching: isSearching ?? this.isSearching,
      stateId: stateId ?? this.stateId,
      importanceId: importanceId ?? this.importanceId,
      urgencyId: urgencyId ?? this.urgencyId,
      serviceId: serviceId ?? this.serviceId,
      dateRange: dateRange ?? this.dateRange,
    );
}
