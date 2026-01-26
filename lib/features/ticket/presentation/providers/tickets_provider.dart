import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../../../presentation/presentation_container.dart';
import '../../data/mappers/ticket_mapper.dart';

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
    final updated = ticket.copyWith(stateId: stateId);
    _optimisticUpdate(updated);
    final payload = _buildTicketPayload(updated);
    return createOrUpdateTicket(payload);
  }

  Future<bool> updateTicketPriority({
    required Ticket ticket,
    int? importanceId,
    int? urgencyId,
    int? stateId,
  }) async {
    final updated = ticket.copyWith(
      importanceId: importanceId ?? ticket.importanceId,
      urgencyId: urgencyId ?? ticket.urgencyId,
      stateId: stateId ?? ticket.stateId,
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

  Future<bool> updateTicketWithComments({
    required Ticket ticket,
    required int stateId,
    required List<String> comments,
    required String authorId,
    required String authorName,
  }) async {
    final now = DateTime.now().toIso8601String();
    final existing = ticket.metadata['comments'];
    final List<Map<String, dynamic>> merged = [];
    if (existing is List) {
      for (final item in existing) {
        if (item is Map<String, dynamic>) {
          merged.add(Map<String, dynamic>.from(item));
        }
      }
    }
    for (final comment in comments) {
      final trimmed = comment.trim();
      if (trimmed.isEmpty) continue;
      merged.add({
        'message': trimmed,
        'authorId': authorId,
        'authorName': authorName,
        'createdAt': now,
      });
    }

    final updatedTicket = ticket.copyWith(
      stateId: stateId,
      metadata: {
        ...ticket.metadata,
        'comments': merged,
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
