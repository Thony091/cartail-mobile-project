import '../../domain/entities/estado_ticket.dart';
import '../../domain/entities/importancia_ticket.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/urgencia_ticket.dart';

class TicketMapper {
  static Ticket jsonToEntity(Map<String, dynamic> json) {
    final estado = _parseEstado(json);
    final importancia = _parseImportancia(json);
    final urgencia = _parseUrgencia(json);

    return Ticket(
      id: _parseInt(json['id']) ?? 0,
      nombre: json['nombre'] as String? ??
          json['title'] as String? ??
          json['name'] as String? ??
          '',
      description: json['description'] as String? ?? json['descripcion'] as String? ?? '',
      desde: _parseDate(json['desde'] ?? json['startDate']),
      hasta: _parseDate(json['hasta'] ?? json['endDate']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
      idServicio: _parseInt(json['idServicio'] ?? json['id_servicio']) ?? 0,
      idUser: json['idUser']?.toString() ??
          json['id_user']?.toString() ??
          json['userId']?.toString(),
      idReserva: json['idReserva']?.toString() ??
          json['id_reserva']?.toString() ??
          json['reservationId']?.toString() ??
          '',
      estado: estado,
      importancia: importancia,
      urgencia: urgencia,
    );
  }

  static Map<String, dynamic> entityToJson(Ticket ticket) => {
        'id': ticket.id,
        'nombre': ticket.nombre,
        'description': ticket.description,
        'desde': ticket.desde?.toIso8601String(),
        'hasta': ticket.hasta?.toIso8601String(),
        'createdAt': ticket.createdAt.toIso8601String(),
        'updatedAt': ticket.updatedAt.toIso8601String(),
        'idServicio': ticket.idServicio,
        'idUser': ticket.idUser,
        'idReserva': ticket.idReserva,
        'idEstado': ticket.estado.id,
        'idImportancia': ticket.importancia.id,
        'idUrgencia': ticket.urgencia.id,
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static EstadoTicket _parseEstado(Map<String, dynamic> json) {
    final data = json['estado'];
    final id = _parseInt(
      data is Map ? data['id'] ?? data['idEstado'] : json['id_estado'] ?? json['idEstado'],
    );
    final nombre = data is Map
        ? (data['nombre'] as String? ?? data['name'] as String?)
        : (json['estadoNombre'] as String? ?? json['estado_nombre'] as String?);
    return EstadoTicket(id: id ?? 1, nombre: nombre ?? '');
  }

  static ImportanciaTicket _parseImportancia(Map<String, dynamic> json) {
    final data = json['importancia'];
    final id = _parseInt(
      data is Map
          ? data['id'] ?? data['idImportancia']
          : json['id_importancia'] ?? json['idImportancia'],
    );
    final nombre = data is Map
        ? (data['nombre'] as String? ?? data['name'] as String?)
        : (json['importanciaNombre'] as String? ??
            json['importancia_nombre'] as String?);
    return ImportanciaTicket(id: id ?? 1, nombre: nombre ?? '');
  }

  static UrgenciaTicket _parseUrgencia(Map<String, dynamic> json) {
    final data = json['urgencia'];
    final id = _parseInt(
      data is Map ? data['id'] ?? data['idUrgencia'] : json['id_urgencia'] ?? json['idUrgencia'],
    );
    final nombre = data is Map
        ? (data['nombre'] as String? ?? data['name'] as String?)
        : (json['urgenciaNombre'] as String? ?? json['urgencia_nombre'] as String?);
    return UrgenciaTicket(id: id ?? 1, nombre: nombre ?? '');
  }
}
