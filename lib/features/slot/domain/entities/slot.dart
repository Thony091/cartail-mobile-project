class Slot {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final int serviceId;
  final int? reservationId;

  Slot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.serviceId,
    this.reservationId,
  });

  bool get isAvailable => reservationId == null || reservationId == 0;
}
