import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_datasource.dart';

class TicketRepositoryRemoteImpl extends TicketRepository {
  TicketRepositoryRemoteImpl({required TicketDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  final TicketDatasource _remoteDatasource;

  @override
  Future<List<Ticket>> getTickets() {
    return _remoteDatasource.getTickets();
  }

  @override
  Future<Ticket> getTicketById(String id) {
    return _remoteDatasource.getTicketById(id);
  }

  @override
  Future<Ticket> createUpdateTicket(Map<String, dynamic> ticketSimilar) {
    return _remoteDatasource.createUpdateTicket(ticketSimilar);
  }

  @override
  Future<void> deleteTicket(String id) {
    return _remoteDatasource.deleteTicket(id);
  }
}
