import '../../domain/entities/ticket.dart';

class TicketModel {
  final String id;
  final String userId;
  final String userName;
  final TicketType type;
  final TicketStatus status;
  final String? assignedToId;
  final String? assignedToName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final int? serviceId;
  final int? stateId;
  final int? importanceId;
  final int? urgencyId;
  final Map<String, dynamic> metadata;

  TicketModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.status,
    this.assignedToId,
    this.assignedToName,
    required this.createdAt,
    this.updatedAt,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.serviceId,
    this.stateId,
    this.importanceId,
    this.urgencyId,
    required this.metadata,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id']?.toString() ?? '',
      userId: json['id_cliente']?.toString() ??
          json['idCliente']?.toString() ??
          json['userId']?.toString() ??
          '',
      userName: json['clienteNombre'] as String? ?? json['userName'] as String? ?? '',
      type: TicketType.fromJson(json['type'] as String? ?? 'reservation'),
      status: _statusFromId(_parseInt(json['id_estado'])),
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
      serviceId: _parseInt(json['id_servicio']),
      stateId: _parseInt(json['id_estado']),
      importanceId: _parseInt(json['id_importancia']),
      urgencyId: _parseInt(json['id_urgencia']),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': assignedToId ?? userId,
      'nombre': title,
      'description': description,
      'desde': startDate,
      'hasta': endDate,
      'id_servicio': serviceId,
      'id_estado': stateId,
      'id_importancia': importanceId,
      'id_urgencia': urgencyId,
      'metadata': metadata,
    };
  }

  Ticket toEntity() {
    return Ticket(
      id: id,
      userId: userId,
      userName: userName,
      type: type,
      status: status,
      assignedToId: assignedToId,
      assignedToName: assignedToName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      serviceId: serviceId,
      stateId: stateId,
      importanceId: importanceId,
      urgencyId: urgencyId,
      metadata: metadata,
    );
  }

  factory TicketModel.fromEntity(Ticket ticket) {
    return TicketModel(
      id: ticket.id,
      userId: ticket.userId,
      userName: ticket.userName,
      type: ticket.type,
      status: ticket.status,
      assignedToId: ticket.assignedToId,
      assignedToName: ticket.assignedToName,
      createdAt: ticket.createdAt,
      updatedAt: ticket.updatedAt,
      title: ticket.title,
      description: ticket.description,
      startDate: ticket.startDate,
      endDate: ticket.endDate,
      serviceId: ticket.serviceId,
      stateId: ticket.stateId,
      importanceId: ticket.importanceId,
      urgencyId: ticket.urgencyId,
      metadata: ticket.metadata,
    );
  }

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
