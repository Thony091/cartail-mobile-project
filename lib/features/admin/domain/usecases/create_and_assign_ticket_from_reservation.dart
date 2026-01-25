import '../entities/admin_ticket_draft.dart';
import '../../../reservation/domain/entities/reservation.dart';
import '../../../reservation/domain/repositories/reservation_repository.dart';
import '../../../reservation/data/models/reservation_model.dart';
import '../../../ticket/domain/entities/ticket.dart';
import '../../../ticket/domain/repositories/ticket_repository.dart';
import '../../../ticket/data/mappers/ticket_mapper.dart';

class AdminOperatorAssignment {
  final String id;
  final String name;

  const AdminOperatorAssignment({
    required this.id,
    required this.name,
  });
}

class CreateAndAssignTicketResult {
  final Ticket ticket;
  final Reservation reservation;

  const CreateAndAssignTicketResult({
    required this.ticket,
    required this.reservation,
  });
}

class CreateAndAssignTicketFromReservation {
  final TicketRepository ticketRepository;
  final ReservationRepository reservationRepository;

  CreateAndAssignTicketFromReservation({
    required this.ticketRepository,
    required this.reservationRepository,
  });

  Future<AdminTicketDraft> buildDraftFromReservation(Reservation reservation) async {
    final startDate = reservation.reservationDate;
    final endDate = reservation.reservationDate;
    final title = reservation.serviceName.isNotEmpty
        ? 'Reserva ${reservation.serviceName}'
        : 'Ticket de reserva';
    final description = _buildDescription(reservation);

    return AdminTicketDraft(
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      serviceId: reservation.serviceId,
      serviceName: reservation.serviceName,
      clientName: reservation.name,
      clientEmail: reservation.email,
      clientRut: reservation.rut,
      priority: 'Normal',
    );
  }

  Future<CreateAndAssignTicketResult> call({
    required String reservationId,
    required AdminTicketDraft draft,
    required AdminOperatorAssignment operator,
  }) async {
    if (reservationId.isEmpty) {
      throw Exception('Reserva inválida');
    }
    if (operator.id.isEmpty) {
      throw Exception('Operario inválido');
    }

    final reservation = await reservationRepository.getReservationById(reservationId);
    if (reservation.id.isEmpty) {
      throw Exception('Reserva no encontrada');
    }

    final tickets = await ticketRepository.getTickets();
    final hasTicket = tickets.any((ticket) => _ticketMatchesReservation(ticket, reservationId));
    if (hasTicket) {
      throw Exception('La reserva ya tiene un ticket asociado');
    }

    final ticketPayload = _buildTicketPayload(
      reservation: reservation,
      draft: draft,
      operator: operator,
    );

    final ticket = await ticketRepository.createUpdateTicket(ticketPayload);

    final updatedReservation = _buildUpdatedReservation(reservation, ticket.id);
    final reservationPayload = ReservationModel.fromEntity(updatedReservation).toJson();
    await reservationRepository.createUpdateReservation(reservationPayload);

    return CreateAndAssignTicketResult(
      ticket: ticket,
      reservation: updatedReservation,
    );
  }

  bool _ticketMatchesReservation(Ticket ticket, String reservationId) {
    final metadataId = ticket.metadata['reservationId'] ?? ticket.metadata['reservation_id'];
    return metadataId?.toString() == reservationId;
  }

  Map<String, dynamic> _buildTicketPayload({
    required Reservation reservation,
    required AdminTicketDraft draft,
    required AdminOperatorAssignment operator,
  }) {
    final now = DateTime.now();
    final fallbackDate =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final ticket = Ticket(
      id: '0',
      userId: reservation.clientId?.toString() ?? '',
      userName: reservation.name,
      type: TicketType.reservation,
      status: TicketStatus.assigned,
      assignedToId: operator.id,
      assignedToName: operator.name,
      createdAt: DateTime.now(),
      title: draft.title,
      description: draft.description,
      startDate: draft.startDate.isNotEmpty ? draft.startDate : fallbackDate,
      endDate: draft.endDate.isNotEmpty ? draft.endDate : fallbackDate,
      serviceId: draft.serviceId ?? reservation.serviceId ?? 1,
      stateId: 2,
      importanceId: 1,
      urgencyId: 1,
      metadata: {
        'reservationId': reservation.id,
        'reservationDate': reservation.reservationDate,
        'reservationTime': reservation.reservationTime,
        'serviceName': reservation.serviceName,
        'clientName': reservation.name,
        'clientEmail': reservation.email,
        'clientRut': reservation.rut,
        'vehiclePlate': reservation.vehiclePlate,
        'priority': draft.priority,
      },
    );

    final payload = TicketMapper.entityToJson(ticket);
    payload['id'] = ticket.id;
    return payload;
  }

  Reservation _buildUpdatedReservation(Reservation reservation, String ticketId) {
    final mechanicNotes = reservation.mechanicNotes;
    final noteSuffix = ticketId.isNotEmpty ? ' Ticket: $ticketId' : '';

    return Reservation(
      id: reservation.id,
      name: reservation.name,
      rut: reservation.rut,
      email: reservation.email,
      reservationDate: reservation.reservationDate,
      reservationTime: reservation.reservationTime,
      serviceName: reservation.serviceName,
      vehiclePlate: reservation.vehiclePlate,
      endTimeEstimated: reservation.endTimeEstimated,
      customerNotes: reservation.customerNotes,
      mechanicNotes: mechanicNotes.isNotEmpty
          ? mechanicNotes
          : 'Ticket creado.$noteSuffix',
      reminder: reservation.reminder,
      statusId: reservation.statusId == null || reservation.statusId == 1
          ? 2
          : reservation.statusId,
      serviceId: reservation.serviceId,
      clientId: reservation.clientId,
    );
  }

  String _buildDescription(Reservation reservation) {
    final parts = <String>[];
    if (reservation.customerNotes.isNotEmpty) {
      parts.add('Notas cliente: ${reservation.customerNotes}');
    }
    if (reservation.vehiclePlate.isNotEmpty) {
      parts.add('Patente: ${reservation.vehiclePlate}');
    }
    if (reservation.reservationTime.isNotEmpty) {
      parts.add('Hora: ${reservation.reservationTime}');
    }
    return parts.join(' | ');
  }
}
