import '../../domain/entities/slot.dart';

class SlotMapper {
  static Slot jsonToEntity(Map<String, dynamic> json) => Slot(
    id: _parseInt(json['id']) ?? 0,
    date: json['fecha'] as String? ?? '',
    startTime: json['horaInicio'] as String? ?? '',
    endTime: json['horaFin'] as String? ?? '',
    serviceId: _parseInt(json['idServicio']) ?? 0,
    reservationId: _parseInt(json['idReserva']),
  );

  static Map<String, dynamic> entityToJson(Slot slot) => {
    'id': slot.id,
    'fecha': slot.date,
    'horaInicio': slot.startTime,
    'horaFin': slot.endTime,
    'idServicio': slot.serviceId,
    'idReserva': slot.reservationId,
  };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    try {
      return int.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
