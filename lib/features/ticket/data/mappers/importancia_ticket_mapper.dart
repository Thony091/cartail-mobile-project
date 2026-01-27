
import 'package:portafolio_project/features/ticket/data/models/importancia_ticket_model.dart';
import 'package:portafolio_project/features/ticket/domain/entities/importancia_ticket.dart';

class ImportanciaTicketMapper {
  static ImportanciaTicket toEntity(ImportanciaTicketModel model) {
    return ImportanciaTicket(
      id: model.id,
      nombre: model.nombre,
    );
  }
  static ImportanciaTicketModel toModel(ImportanciaTicket entity) {
    return ImportanciaTicketModel(
      id: entity.id,
      nombre: entity.nombre,
    );
  }
}