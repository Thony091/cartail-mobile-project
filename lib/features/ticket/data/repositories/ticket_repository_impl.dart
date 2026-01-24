import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_datasource.dart';

class TicketRepositoryImpl extends TicketRepository {
  final TicketDatasource ticketDatasource;

  TicketRepositoryImpl(this.ticketDatasource);

  @override
  Future<Ticket> createUpdateTicket(Map<String, dynamic> ticketSimilar) {
    return ticketDatasource.createUpdateTicket(ticketSimilar);
  }

  @override
  Future<void> deleteTicket(String id) {
    return ticketDatasource.deleteTicket(id);
  }

  @override
  Future<Ticket> getTicketById(String id) {
    return ticketDatasource.getTicketById(id);
  }

  @override
  Future<List<Ticket>> getTickets() {
    return ticketDatasource.getTickets();
  }
}
