import '../../domain/entities/slot.dart';

class SlotMapper {
  static Slot jsonToEntity(Map<String, dynamic> json) => Slot(
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

  static Map<String, dynamic> entityToJson(Slot slot) => {
    'id': slot.id,
    'id_service': slot.serviceId,
    'start_time': slot.startTime.toIso8601String(),
    'end_time': slot.endTime.toIso8601String(),
    'estimated_end_time': slot.estimatedEndTime.toIso8601String(),
    'note': slot.note,
    'active': slot.isActive,
    'created_at': slot.createdAt.toIso8601String(),
  };
}
