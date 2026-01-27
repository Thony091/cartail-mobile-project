
import 'package:portafolio_project/features/ticket/data/models/estado_ticket_model.dart';
import 'package:portafolio_project/features/ticket/domain/entities/estado_ticket.dart';

class EstadoTicketMapper {
  static EstadoTicket toEntity(EstadoTicketModel model) {
    return EstadoTicket(
      id: model.id,
      nombre: model.nombre,
    );
  }
  static EstadoTicketModel toModel(EstadoTicket entity) {
    return EstadoTicketModel(
      id: entity.id,
      nombre: entity.nombre,
    );
  }
}