import '../../domain/entities/ticket.dart';

class TicketMapper {
  static Ticket jsonToEntity(Map<String, dynamic> json) => Ticket(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    userName: json['userName'] as String? ?? '',
    type: TicketType.fromJson(json['type'] as String? ?? 'order'),
    status: TicketStatus.fromJson(json['status'] as String? ?? 'pending'),
    assignedToId: json['assignedToId']?.toString(),
    assignedToName: json['assignedToName'] as String?,
    createdAt: json['createdAt'] != null
      ? DateTime.parse(json['createdAt'] as String)
      : DateTime.now(),
    updatedAt: json['updatedAt'] != null
      ? DateTime.parse(json['updatedAt'] as String)
      : null,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    metadata: json['metadata'] as Map<String, dynamic>? ?? {},
  );

  static Map<String, dynamic> entityToJson(Ticket ticket) => {
    'id': ticket.id,
    'userId': ticket.userId,
    'userName': ticket.userName,
    'type': ticket.type.toJson(),
    'status': ticket.status.toJson(),
    if (ticket.assignedToId != null) 'assignedToId': ticket.assignedToId,
    if (ticket.assignedToName != null) 'assignedToName': ticket.assignedToName,
    'createdAt': ticket.createdAt.toIso8601String(),
    if (ticket.updatedAt != null) 'updatedAt': ticket.updatedAt!.toIso8601String(),
    'title': ticket.title,
    'description': ticket.description,
    'metadata': ticket.metadata,
  };
}
