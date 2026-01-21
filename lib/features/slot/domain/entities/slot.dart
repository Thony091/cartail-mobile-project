class Slot {
  final int id;
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime estimatedEndTime;
  final String note;
  final bool isActive;
  final DateTime createdAt;

  Slot({
    required this.id,
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    required this.estimatedEndTime,
    required this.note,
    required this.isActive,
    required this.createdAt,
  });
}
