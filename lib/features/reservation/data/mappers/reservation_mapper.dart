
import '../../domain/entities/reservation.dart';


class ReservationMapper {

  static jsonToEntity( Map<String, dynamic> json) {
    final cliente = json['cliente'];
    final clienteData = cliente is Map<String, dynamic> ? cliente : null;
    final clienteNombre = clienteData?['nombre'] as String?;
    final clienteRut = clienteData?['rut'] as String?;
    final clienteEmail = clienteData?['email'] as String?;
    final servicio = json['servicio'];
    final servicioData = servicio is Map<String, dynamic> ? servicio : null;
    final servicioNombre = servicioData?['nombre'] as String?;

    return Reservation(
      id: json['id'].toString(), 
      name: json['nombre'] ?? json['name'] ?? clienteNombre ?? json['patenteVehiculo'] ?? '',
      rut: json['rut'] ?? clienteRut ?? '',
      email: json['email'] ?? clienteEmail ?? '',
      reservationDate: json['fecha']  ?? json['reservationDate'] ?? '',
      reservationTime: json['horaInicio']  ?? json['reservationTime'] ?? '',
      // reservationDate: DateTime.parse(json['reservationDate'])  ?? DateTime.now(),
      // reservationTime: _processTimeString(json['reservationTime']) ,
      serviceName: servicioNombre ?? json['serviceName'] ?? json['idServicio']?.toString() ?? '',
      vehiclePlate: json['patenteVehiculo'] ?? '',
      endTimeEstimated: json['horaFinEstimada'] ?? '',
      customerNotes: json['notasCliente'] ?? '',
      mechanicNotes: json['notasMecanico'] ?? '',
      reminder: json['recordatorio'] ?? false,
      statusId: json['idEstado'] != null ? _parseInt(json['idEstado']) : null,
      serviceId: json['idServicio'] != null ? _parseInt(json['idServicio']) : null,
      clientId: json['idCliente'] != null ? _parseInt(json['idCliente']) : null,
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
