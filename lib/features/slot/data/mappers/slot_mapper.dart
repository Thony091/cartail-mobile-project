import '../../domain/entities/slot.dart';

class SlotMapper {
  static Slot jsonToEntity(Map<String, dynamic> json) => Slot(
    id: _parseInt(json['id']) ?? 0,
    date: json['fecha'] as String? ?? _extractDate(json['inicio']) ?? '',
    startTime: json['horaInicio'] as String? ?? _extractTime(json['inicio']) ?? '',
    endTime: json['horaFin'] as String? ?? _extractTime(json['fin']) ?? '',
    serviceId: _parseInt(json['idServicio'] ?? json['servicioId']) ?? 0,
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

  static String? _extractDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      final local = parsed.toLocal();
      return '${local.year.toString().padLeft(4, '0')}-'
          '${local.month.toString().padLeft(2, '0')}-'
          '${local.day.toString().padLeft(2, '0')}';
    }
    if (text.length >= 10) return text.substring(0, 10);
    return null;
  }

  static String? _extractTime(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      final local = parsed.toLocal();
      return '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
    }
    if (text.contains('T') && text.length >= 16) {
      return text.substring(11, 16);
    }
    if (text.length >= 5) return text.substring(0, 5);
    return null;
  }
}
