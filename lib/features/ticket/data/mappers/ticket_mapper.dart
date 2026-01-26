import '../../domain/entities/ticket.dart';

class TicketMapper {
  static Ticket jsonToEntity(Map<String, dynamic> json) => Ticket(
    id: json['id']?.toString() ?? '',
    userId: json['id_cliente']?.toString() ??
        json['idCliente']?.toString() ??
        json['userId']?.toString() ??
        '',
    userName: json['clienteNombre'] as String? ??
        json['userName'] as String? ??
        '',
    type: TicketType.fromJson(json['type'] as String? ?? 'reservation'),
    status: _statusFromId(
      _parseInt(json['id_estado'] ?? json['idEstado'] ?? json['stateId']),
    ),
    assignedToId: json['id_user']?.toString() ?? json['assignedToId']?.toString(),
    assignedToName: json['assignedToName'] as String?,
    createdAt: json['createdAt'] != null
      ? DateTime.parse(json['createdAt'] as String)
      : DateTime.now(),
    updatedAt: json['updatedAt'] != null
      ? DateTime.parse(json['updatedAt'] as String)
      : null,
    title: json['nombre'] as String? ?? json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    startDate: json['desde'] as String? ?? '',
    endDate: json['hasta'] as String? ?? '',
    serviceId: _parseInt(
      json['id_servicio'] ?? json['idServicio'] ?? json['serviceId'],
    ),
    stateId: _parseInt(
      json['id_estado'] ?? json['idEstado'] ?? json['stateId'],
    ),
    importanceId: _parseInt(
      json['id_importancia'] ?? json['idImportancia'] ?? json['importanceId'],
    ),
    urgencyId: _parseInt(
      json['id_urgencia'] ?? json['idUrgencia'] ?? json['urgencyId'],
    ),
    metadata: json['metadata'] as Map<String, dynamic>? ?? {},
  );

  static Map<String, dynamic> entityToJson(Ticket ticket) => {
    'id': ticket.id,
    'id_user': ticket.assignedToId ?? ticket.userId,
    'nombre': ticket.title,
    'description': ticket.description,
    'desde': ticket.startDate,
    'hasta': ticket.endDate,
    'id_servicio': ticket.serviceId,
    'id_estado': ticket.stateId,
    'id_importancia': ticket.importanceId,
    'id_urgencia': ticket.urgencyId,
    'metadata': ticket.metadata,
  };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  static TicketStatus _statusFromId(int? id) {
    switch (id) {
      case 1:
        return TicketStatus.pending;
      case 2:
        return TicketStatus.assigned;
      case 3:
        return TicketStatus.inProgress;
      case 4:
        return TicketStatus.completed;
      case 5:
        return TicketStatus.completed;
      default:
        return TicketStatus.pending;
    }
  }
}
