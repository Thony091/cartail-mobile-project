import '../../domain/entities/reservation.dart';

class ReservationModel {
  final String id;
  final String name;
  final String rut;
  final String email;
  final String reservationDate;
  final String reservationTime;
  final String serviceName;

  ReservationModel({
    required this.id,
    required this.name,
    required this.rut,
    required this.email,
    required this.reservationDate,
    required this.reservationTime,
    required this.serviceName,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      rut: json['rut'] as String? ?? '',
      email: json['email'] as String? ?? '',
      reservationDate: json['reservationDate'] as String? ?? '',
      reservationTime: json['reservationTime'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rut': rut,
      'email': email,
      'reservationDate': reservationDate,
      'reservationTime': reservationTime,
      'serviceName': serviceName,
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
    );
  }
}
