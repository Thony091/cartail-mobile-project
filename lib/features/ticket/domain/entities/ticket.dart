/// Tipo de ticket en el sistema
enum TicketType {
  /// Reserva de trabajo/servicio
  reservation,

  /// Compra de producto
  purchase,

  /// Pedido personalizado
  order;

  String toJson() => name;

  static TicketType fromJson(String value) {
    return TicketType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TicketType.order,
    );
  }
}

/// Estado del ticket
enum TicketStatus {
  /// Pendiente de asignación
  pending,

  /// Asignado a un operario
  assigned,

  /// En progreso
  inProgress,

  /// Completado
  completed,

  /// Cancelado
  cancelled;

  String toJson() => name;

  static TicketStatus fromJson(String value) {
    return TicketStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => TicketStatus.pending,
    );
  }
}

/// Entidad que representa un ticket en el sistema.
///
/// Los tickets pueden ser reservas, compras o pedidos que son
/// asignados a operarios para su gestión.
class Ticket {
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
  final Map<String, dynamic> metadata;

  Ticket({
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
    required this.metadata,
  });

  /// Verifica si el ticket está asignado a un operario
  bool get isAssigned => assignedToId != null;

  /// Verifica si el ticket está pendiente de asignación
  bool get isPending => status == TicketStatus.pending;

  /// Verifica si el ticket está completado
  bool get isCompleted => status == TicketStatus.completed;

  /// Verifica si el ticket está en progreso
  bool get isInProgress => status == TicketStatus.inProgress;

  /// Crea una copia del ticket con los campos especificados modificados
  Ticket copyWith({
    String? id,
    String? userId,
    String? userName,
    TicketType? type,
    TicketStatus? status,
    String? assignedToId,
    String? assignedToName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return Ticket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      status: status ?? this.status,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }
}
