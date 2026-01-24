import '../../domain/entities/reservation.dart';

class ReservationModel {
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
  final bool reminder;
  final int? statusId;
  final int? serviceId;
  final int? clientId;

  ReservationModel({
    required this.id,
    required this.name,
    required this.rut,
    required this.email,
    required this.reservationDate,
    required this.reservationTime,
    required this.serviceName,
    required this.vehiclePlate,
    required this.endTimeEstimated,
    required this.customerNotes,
    required this.mechanicNotes,
    required this.reminder,
    this.statusId,
    this.serviceId,
    this.clientId,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final cliente = json['cliente'];
    final clienteData = cliente is Map<String, dynamic> ? cliente : null;
    final clienteNombre = clienteData?['nombre'] as String?;
    final clienteRut = clienteData?['rut'] as String?;
    final clienteEmail = clienteData?['email'] as String?;

    return ReservationModel(
      id: json['id']?.toString() ?? '',
      name: json['nombre'] as String? ??
          json['name'] as String? ??
          clienteNombre ??
          json['patenteVehiculo'] as String? ??
          '',
      rut: json['rut'] as String? ?? clienteRut ?? '',
      email: json['email'] as String? ?? clienteEmail ?? '',
      reservationDate:
          json['fecha'] as String? ?? json['reservationDate'] as String? ?? '',
      reservationTime: json['horaInicio'] as String? ??
          json['reservationTime'] as String? ??
          '',
      serviceName: json['servicio']?['nombre'] as String? ??
          json['serviceName'] as String? ??
          json['idServicio']?.toString() ??
          '',
      vehiclePlate: json['patenteVehiculo'] as String? ?? '',
      endTimeEstimated: json['horaFinEstimada'] as String? ?? '',
      customerNotes: json['notasCliente'] as String? ?? '',
      mechanicNotes: json['notasMecanico'] as String? ?? '',
      reminder: json['recordatorio'] as bool? ?? false,
      statusId: json['idEstado'] != null ? _parseInt(json['idEstado']) : null,
      serviceId: json['idServicio'] != null ? _parseInt(json['idServicio']) : null,
      clientId: json['idCliente'] != null ? _parseInt(json['idCliente']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'rut': rut,
      'email': email,
      'fecha': reservationDate,
      'horaInicio': reservationTime,
      'horaFinEstimada': endTimeEstimated,
      'patenteVehiculo': vehiclePlate,
      'notasCliente': customerNotes,
      'notasMecanico': mechanicNotes,
      'recordatorio': reminder,
      if (statusId != null) 'idEstado': statusId,
      if (serviceId != null) 'idServicio': serviceId,
      if (clientId != null) 'idCliente': clientId,
    };
  }

  Reservation toEntity() {
    return Reservation(
      id: id,
      name: name,
      rut: rut,
      email: email,
      reservationDate: reservationDate,
      reservationTime: reservationTime,
      serviceName: serviceName,
      vehiclePlate: vehiclePlate,
      endTimeEstimated: endTimeEstimated,
      customerNotes: customerNotes,
      mechanicNotes: mechanicNotes,
      reminder: reminder,
      statusId: statusId,
      serviceId: serviceId,
      clientId: clientId,
    );
  }

  factory ReservationModel.fromEntity(Reservation reservation) {
    return ReservationModel(
      id: reservation.id,
      name: reservation.name,
      rut: reservation.rut,
      email: reservation.email,
      reservationDate: reservation.reservationDate,
      reservationTime: reservation.reservationTime,
      serviceName: reservation.serviceName,
      vehiclePlate: reservation.vehiclePlate,
      endTimeEstimated: reservation.endTimeEstimated,
      customerNotes: reservation.customerNotes,
      mechanicNotes: reservation.mechanicNotes,
      reminder: reservation.reminder,
      statusId: reservation.statusId,
      serviceId: reservation.serviceId,
      clientId: reservation.clientId,
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }
}
