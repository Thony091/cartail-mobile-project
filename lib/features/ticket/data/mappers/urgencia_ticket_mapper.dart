
import 'package:portafolio_project/features/ticket/data/models/urgencia_ticket_model.dart';
import 'package:portafolio_project/features/ticket/domain/entities/urgencia_ticket.dart';

class UrgenciaTicketMapper {
  static UrgenciaTicket toModel(UrgenciaTicketModel model) => UrgenciaTicket(
    id: model.id,
    nombre: model.nombre,
  );
  static UrgenciaTicketModel toEntity(UrgenciaTicket entity) => UrgenciaTicketModel(
    id: entity.id,
    nombre:  entity.nombre,
  );
}