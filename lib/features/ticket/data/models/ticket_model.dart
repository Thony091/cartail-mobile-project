import '../../domain/entities/ticket.dart';
import '../mappers/ticket_mapper.dart';

class TicketModel {
  final Ticket ticket;

  TicketModel({required this.ticket});

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(ticket: TicketMapper.jsonToEntity(json));
  }

  Map<String, dynamic> toJson() {
    return TicketMapper.entityToJson(ticket);
  }

  Ticket toEntity() {
    return ticket;
  }

  factory TicketModel.fromEntity(Ticket ticket) {
    return TicketModel(ticket: ticket);
  }
}
