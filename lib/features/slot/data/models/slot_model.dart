import '../../domain/entities/slot.dart';

class SlotModel {
  final int id;
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime estimatedEndTime;
  final String note;
  final bool isActive;
  final DateTime createdAt;

  SlotModel({
    required this.id,
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    required this.estimatedEndTime,
    required this.note,
    required this.isActive,
    required this.createdAt,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] as int,
      serviceId: json['id_service']?.toString() ?? '',
      startTime: json['start_time'] != null
        ? DateTime.parse(json['start_time'] as String)
        : DateTime.now(),
      endTime: json['end_time'] != null
        ? DateTime.parse(json['end_time'] as String)
        : DateTime.now(),
      estimatedEndTime: json['estimated_end_time'] != null
        ? DateTime.parse(json['estimated_end_time'] as String)
        : DateTime.now(),
      note: json['note'] as String? ?? '',
      isActive: json['active'] as bool? ?? true,
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_service': serviceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'estimated_end_time': estimatedEndTime.toIso8601String(),
      'note': note,
      'active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Slot toEntity() {
    return Slot(
      id: id,
      serviceId: serviceId,
      startTime: startTime,
      endTime: endTime,
      estimatedEndTime: estimatedEndTime,
      note: note,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  factory SlotModel.fromEntity(Slot slot) {
    return SlotModel(
      id: slot.id,
      serviceId: slot.serviceId,
      startTime: slot.startTime,
      endTime: slot.endTime,
      estimatedEndTime: slot.estimatedEndTime,
      note: slot.note,
      isActive: slot.isActive,
      createdAt: slot.createdAt,
    );
  }
}
