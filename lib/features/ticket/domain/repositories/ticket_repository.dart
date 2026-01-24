import '../entities/ticket.dart';

abstract class TicketRepository {
  Future<List<Ticket>> getTickets();
  Future<Ticket> getTicketById(String id);
  Future<Ticket> createUpdateTicket(Map<String, dynamic> ticketSimilar);
  Future<void> deleteTicket(String id);
}
