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
    required this.metadata,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
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
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type.toJson(),
      'status': status.toJson(),
      if (assignedToId != null) 'assignedToId': assignedToId,
      if (assignedToName != null) 'assignedToName': assignedToName,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'title': title,
      'description': description,
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
      metadata: ticket.metadata,
    );
  }
}
