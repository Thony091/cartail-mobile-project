import '../../domain/entities/slot.dart';

class SlotModel {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final int serviceId;
  final int? reservationId;

  SlotModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.serviceId,
    this.reservationId,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: _parseInt(json['id']) ?? 0,
      date: json['fecha'] as String? ?? '',
      startTime: json['horaInicio'] as String? ?? '',
      endTime: json['horaFin'] as String? ?? '',
      serviceId: _parseInt(json['idServicio']) ?? 0,
      reservationId: _parseInt(json['idReserva']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': date,
      'horaInicio': startTime,
      'horaFin': endTime,
      'idServicio': serviceId,
      'idReserva': reservationId,
    };
  }

  Slot toEntity() {
    return Slot(
      id: id,
      date: date,
      startTime: startTime,
      endTime: endTime,
      serviceId: serviceId,
      reservationId: reservationId,
    );
  }

  factory SlotModel.fromEntity(Slot slot) {
    return SlotModel(
      id: slot.id,
      date: slot.date,
      startTime: slot.startTime,
      endTime: slot.endTime,
      serviceId: slot.serviceId,
      reservationId: slot.reservationId,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    try {
      return int.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
