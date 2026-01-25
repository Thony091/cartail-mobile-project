import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/better_auth_provider.dart';
import '../../../auth/data/datasources/admin_auth_datasource.dart';
import '../../../auth/data/models/admin_response_models.dart';
import '../../../auth/presentation/providers/admin_auth_provider.dart';
import '../../../reservation/domain/entities/reservation.dart';
import '../../../reservation/domain/repositories/reservation_repository.dart';
import '../../../reservation/presentation/providers/reservation_provider.dart';
import '../../../reservation/presentation/providers/reservation_repository_provider.dart';
import '../../../ticket/domain/entities/ticket.dart';
import '../../../ticket/domain/repositories/ticket_repository.dart';
import '../../../ticket/presentation/providers/tickets_provider.dart';
import '../../../ticket/presentation/providers/tickets_repository_provider.dart';
import '../../domain/entities/admin_ticket_draft.dart';
import '../../domain/usecases/create_and_assign_ticket_from_reservation.dart';

class AdminReservationSummary {
  final String id;
  final String clientName;
  final String clientEmail;
  final String clientRut;
  final String serviceName;
  final String date;
  final String priority;
  final String summary;
  final int? serviceId;
  final String reservationTime;

  const AdminReservationSummary({
    required this.id,
    required this.clientName,
    required this.clientEmail,
    required this.clientRut,
    required this.serviceName,
    required this.date,
    required this.priority,
    required this.summary,
    required this.serviceId,
    required this.reservationTime,
  });
}

class AdminTicketSummary {
  final String id;
  final String title;
  final String description;
  final String serviceName;
  final String date;
  final String priority;
  final String? assignedToId;
  final String? assignedToName;
  final String? reservationId;
  final int? stateId;

  const AdminTicketSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceName,
    required this.date,
    required this.priority,
    required this.assignedToId,
    required this.assignedToName,
    required this.reservationId,
    required this.stateId,
  });

  bool get isAssigned => assignedToId != null && assignedToId!.isNotEmpty;
}

class AdminOperatorSummary {
  final String id;
  final String name;
  final String email;
  final bool isActive;

  const AdminOperatorSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
  });

  factory AdminOperatorSummary.fromAdmin(AdminUserModel user) {
    return AdminOperatorSummary(
      id: user.id,
      name: user.name ?? user.email,
      email: user.email,
      isActive: !user.isCurrentlyBanned,
    );
  }
}

class AdminTicketAssignmentFilters {
  final DateTime? date;
  final String serviceType;
  final String priority;

  const AdminTicketAssignmentFilters({
    this.date,
    this.serviceType = 'Todas',
    this.priority = 'Todas',
  });

  AdminTicketAssignmentFilters copyWith({
    DateTime? date,
    String? serviceType,
    String? priority,
  }) {
    return AdminTicketAssignmentFilters(
      date: date,
      serviceType: serviceType ?? this.serviceType,
      priority: priority ?? this.priority,
    );
  }
}

class AdminTicketAssignmentState {
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final List<AdminReservationSummary> pendingReservations;
  final List<AdminTicketSummary> createdTickets;
  final List<AdminOperatorSummary> operators;
  final AdminTicketAssignmentFilters filters;

  const AdminTicketAssignmentState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.pendingReservations = const [],
    this.createdTickets = const [],
    this.operators = const [],
    this.filters = const AdminTicketAssignmentFilters(),
  });

  AdminTicketAssignmentState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    List<AdminReservationSummary>? pendingReservations,
    List<AdminTicketSummary>? createdTickets,
    List<AdminOperatorSummary>? operators,
    AdminTicketAssignmentFilters? filters,
  }) {
    return AdminTicketAssignmentState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingReservations: pendingReservations ?? this.pendingReservations,
      createdTickets: createdTickets ?? this.createdTickets,
      operators: operators ?? this.operators,
      filters: filters ?? this.filters,
    );
  }
}

class AdminTicketAssignmentController extends StateNotifier<AdminTicketAssignmentState> {
  final Ref ref;
  final TicketRepository ticketRepository;
  final ReservationRepository reservationRepository;
  final AdminAuthDatasource adminAuthDatasource;
  final CreateAndAssignTicketFromReservation createAndAssignUseCase;

  final Map<String, Reservation> _reservationCache = {};

  AdminTicketAssignmentController({
    required this.ref,
    required this.ticketRepository,
    required this.reservationRepository,
    required this.adminAuthDatasource,
    required this.createAndAssignUseCase,
  }) : super(const AdminTicketAssignmentState());

  Future<void> loadInitial({bool force = false}) async {
    if (state.isLoading && !force) return;

    final authState = ref.read(betterAuthProvider);
    if (!authState.isAdmin) {
      state = state.copyWith(errorMessage: 'Acceso exclusivo para administradores');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final reservations = await reservationRepository.getReservations();
      final tickets = await ticketRepository.getTickets();
      final operatorsResponse = await adminAuthDatasource.listUsers(
        limit: 100,
        offset: 0,
        filterField: 'role',
        filterOperator: 'eq',
        filterValue: 'operator',
      );

      _reservationCache
        ..clear()
        ..addEntries(reservations.map((reservation) => MapEntry(reservation.id, reservation)));

      final ticketReservationIds = _mapReservationIds(tickets);
      final pending = reservations
          .where((reservation) => !ticketReservationIds.contains(reservation.id))
          .map(_mapReservationSummary)
          .toList();

      final createdTickets = tickets
          .where((ticket) => _reservationIdFromTicket(ticket) != null)
          .map(_mapTicketSummary)
          .toList();

      final operators = operatorsResponse.users
          .map(AdminOperatorSummary.fromAdmin)
          .where((operator) => operator.isActive)
          .toList();

      state = state.copyWith(
        isLoading: false,
        pendingReservations: pending,
        createdTickets: createdTickets,
        operators: operators,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void updateDateFilter(DateTime? date) {
    state = state.copyWith(filters: state.filters.copyWith(date: date));
  }

  void updateServiceFilter(String value) {
    state = state.copyWith(filters: state.filters.copyWith(serviceType: value));
  }

  void updatePriorityFilter(String value) {
    state = state.copyWith(filters: state.filters.copyWith(priority: value));
  }

  Future<AdminTicketDraft?> buildDraft(String reservationId) async {
    final reservation = _reservationCache[reservationId];
    if (reservation == null) return null;
    return createAndAssignUseCase.buildDraftFromReservation(reservation);
  }

  Future<bool> createAndAssignTicket({
    required String reservationId,
    required AdminTicketDraft draft,
    required AdminOperatorSummary operator,
  }) async {
    if (state.isSubmitting) return false;

    final authState = ref.read(betterAuthProvider);
    if (!authState.isAdmin) {
      state = state.copyWith(errorMessage: 'Acceso exclusivo para administradores');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: '');

    try {
      final result = await createAndAssignUseCase(
        reservationId: reservationId,
        draft: draft,
        operator: AdminOperatorAssignment(id: operator.id, name: operator.name),
      );

      _reservationCache.remove(reservationId);

      final updatedPending = state.pendingReservations
          .where((reservation) => reservation.id != reservationId)
          .toList();
      final updatedTickets = [
        _mapTicketSummary(result.ticket),
        ...state.createdTickets,
      ];

      state = state.copyWith(
        isSubmitting: false,
        pendingReservations: updatedPending,
        createdTickets: updatedTickets,
      );

      await ref.read(ticketsProvider.notifier).getTickets();
      await ref.read(reservationProvider.notifier).getReservations();

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Set<String> _mapReservationIds(List<Ticket> tickets) {
    final ids = <String>{};
    for (final ticket in tickets) {
      final reservationId = _reservationIdFromTicket(ticket);
      if (reservationId != null && reservationId.isNotEmpty) {
        ids.add(reservationId);
      }
    }
    return ids;
  }

  String? _reservationIdFromTicket(Ticket ticket) {
    final metadataId = ticket.metadata['reservationId'] ?? ticket.metadata['reservation_id'];
    return metadataId?.toString();
  }

  AdminReservationSummary _mapReservationSummary(Reservation reservation) {
    final summary = reservation.customerNotes.isNotEmpty
        ? reservation.customerNotes
        : reservation.mechanicNotes;

    return AdminReservationSummary(
      id: reservation.id,
      clientName: reservation.name,
      clientEmail: reservation.email,
      clientRut: reservation.rut,
      serviceName: reservation.serviceName,
      date: reservation.reservationDate,
      priority: 'Normal',
      summary: summary,
      serviceId: reservation.serviceId,
      reservationTime: reservation.reservationTime,
    );
  }

  AdminTicketSummary _mapTicketSummary(Ticket ticket) {
    final metadata = ticket.metadata;
    final priority = metadata['priority']?.toString() ?? 'Normal';
    final serviceName = metadata['serviceName']?.toString() ?? '';
    final date = metadata['reservationDate']?.toString() ?? ticket.startDate;

    return AdminTicketSummary(
      id: ticket.id,
      title: ticket.title,
      description: ticket.description,
      serviceName: serviceName,
      date: date,
      priority: priority,
      assignedToId: ticket.assignedToId,
      assignedToName: ticket.assignedToName,
      reservationId: _reservationIdFromTicket(ticket),
      stateId: ticket.stateId,
    );
  }
}

final adminTicketAssignmentControllerProvider =
    StateNotifierProvider<AdminTicketAssignmentController, AdminTicketAssignmentState>((ref) {
  final ticketRepository = ref.watch(ticketsRepositoryProvider);
  final reservationRepository = ref.watch(reservationRepositoryProvider);
  final adminAuthDatasource = ref.watch(adminAuthDatasourceProvider);

  final useCase = CreateAndAssignTicketFromReservation(
    ticketRepository: ticketRepository,
    reservationRepository: reservationRepository,
  );

  return AdminTicketAssignmentController(
    ref: ref,
    ticketRepository: ticketRepository,
    reservationRepository: reservationRepository,
    adminAuthDatasource: adminAuthDatasource,
    createAndAssignUseCase: useCase,
  );
});
