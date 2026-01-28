class Reservation{

  final String id;
  final String name;
  final String rut;
  final String email;
  final String reservationDate;
  final String reservationTime;
  final String serviceName;
  final String vehiclePlate;
  final String endTimeEstimated;
  final String customerNotes;
  final String mechanicNotes;
  final String idTransaccion;
  final bool reminder;
  final int? statusId;
  final int? serviceId;
  final int? clientId;
  final int? slotId;

  Reservation({
    required this.id,
    required this.name,
    required this.rut,
    required this.email,
    required this.reservationDate,
    required this.reservationTime,
    required this.serviceName,
    required this.idTransaccion,
    this.vehiclePlate = '',
    this.endTimeEstimated = '',
    this.customerNotes = '',
    this.mechanicNotes = '',
    this.reminder = false,
    this.statusId,
    this.serviceId,
    this.clientId,
    this.slotId,
  });
}
