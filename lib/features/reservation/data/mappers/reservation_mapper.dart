
import 'package:flutter/foundation.dart';

import '../../domain/entities/reservation.dart';

class ReservationMapper {
  /// Mapea JSON del backend a entidad Reservation
  /// Soporta múltiples formatos de respuesta del API
  static Reservation jsonToEntity(Map<String, dynamic> json) {
    // DEBUG: Imprime el JSON si está en modo debug
    if (kDebugMode) {
      print('\x1B[31m');
      print('═══════════════════════════════════════════════════════');
      print('[ReservationMapper] 🔴 JSON RECIBIDO DEL BACKEND:');
      print('═══════════════════════════════════════════════════════');
      print(json.toString());
      print('═══════════════════════════════════════════════════════');
      print('\x1B[0m');
    }

    // Extrae datos del cliente (puede venir en objeto anidado o en raíz)
    final clienteData = _extractClientData(json);

    // Intenta obtener nombre: primero de la raíz, luego del cliente enriquecido
    final nombre = _extractString(
      json,
      ['nombre', 'name', 'customerName', 'client_name'],
      fallback: clienteData['nombre'] ?? clienteData['name'] ?? '',
    );

    final rut = _extractString(
      json,
      ['rut', 'customer_rut', 'clientRut'],
      fallback: clienteData['rut'] ?? '',
    );

    // Intenta obtener email: primero de la raíz, luego del cliente enriquecido
    final email = _extractString(
      json,
      ['email', 'customerEmail', 'client_email'],
      fallback: clienteData['email'] ?? clienteData['mail'] ?? '',
    );

    // Extrae datos del servicio
    final servicioData = _extractServiceData(json);
    final serviceName = _extractString(
      json,
      ['serviceName', 'service_name'],
      fallback: servicioData['nombre'] ?? json['idServicio']?.toString() ?? '',
    );

    // Extrae fechas y horas
    final reservationDate = _extractString(
      json,
      ['fecha', 'reservationDate', 'reservation_date', 'date'],
    );
    final reservationTime = _extractString(
      json,
      ['horaInicio', 'reservationTime', 'reservation_time', 'startTime', 'start_time', 'hora'],
    );

    final endTimeEstimated = _extractString(
      json,
      ['horaFinEstimada', 'endTimeEstimated', 'end_time_estimated', 'horaFin'],
    );

    final vehiclePlate = _extractString(
      json,
      ['patenteVehiculo', 'vehiclePlate', 'vehicle_plate', 'patente', 'plate'],
    );

    // DEBUG: Imprime los valores extraídos
    if (kDebugMode) {
      final hasClientData = clienteData.isNotEmpty;
      print('\x1B[33m');
      print('═══════════════════════════════════════════════════════');
      print('[ReservationMapper] 🟡 VALORES EXTRAÍDOS:');
      if (hasClientData) {
        print('  📌 Datos de Cliente ENRIQUECIDOS: ${clienteData['nombre'] ?? 'N/A'}');
      }
      print('═══════════════════════════════════════════════════════');
      print('  ✓ nombre: "$nombre" ${nombre.isEmpty ? '❌ VACÍO' : '✅'}');
      print('  ✓ email: "$email" ${email.isEmpty ? '❌ VACÍO' : '✅'}');
      print('  ✓ serviceName: "$serviceName" ${serviceName.isEmpty ? '❌ VACÍO' : '✅'}');
      print('  ✓ fecha: "$reservationDate" ${reservationDate.isEmpty ? '❌ VACÍO' : '✅'}');
      print('  ✓ hora: "$reservationTime" ${reservationTime.isEmpty ? '❌ VACÍO' : '✅'}');
      print('  ✓ patente: "$vehiclePlate" ${vehiclePlate.isEmpty ? '❌ VACÍO' : '✅'}');
      print('═══════════════════════════════════════════════════════');
      print('\x1B[0m');
    }

    return Reservation(
      id: _extractString(json, ['id']),
      name: nombre,
      rut: rut,
      email: email,
      reservationDate: reservationDate,
      reservationTime: reservationTime,
      serviceName: serviceName,
      vehiclePlate: vehiclePlate,
      endTimeEstimated: endTimeEstimated,
      idTransaccion: _extractString(json, ['idTransaccion', 'transactionId', 'transaction_id']),
      customerNotes: _extractString(
        json,
        ['notasCliente', 'customerNotes', 'customer_notes', 'notes'],
      ),
      mechanicNotes: _extractString(
        json,
        ['notasMecanico', 'mechanicNotes', 'mechanic_notes'],
      ),
      reminder: _extractBool(json, ['recordatorio', 'reminder'], defaultValue: false),
      statusId: _extractInt(json, ['idEstado', 'statusId', 'status_id', 'estado']),
      serviceId: _extractInt(json, ['idServicio', 'serviceId', 'service_id']),
      clientId: _extractInt(json, ['idCliente', 'clientId', 'client_id']),
      slotId: _extractInt(json, ['idSlot', 'slotId', 'slot_id']),
    );
  }

  /// Extrae datos del cliente desde estructura anidada
  static Map<String, dynamic> _extractClientData(Map<String, dynamic> json) {
    final cliente = json['cliente'] ?? json['client'] ?? json['customer'];
    if (cliente is Map<String, dynamic>) {
      return cliente;
    }
    return {};
  }

  /// Extrae datos del servicio desde estructura anidada
  static Map<String, dynamic> _extractServiceData(Map<String, dynamic> json) {
    final servicio = json['servicio'] ?? json['service'];
    if (servicio is Map<String, dynamic>) {
      return servicio;
    }
    return {};
  }

  /// Extrae string desde cualquiera de las claves posibles
  static String _extractString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      } else if (value != null) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  /// Extrae entero desde cualquiera de las claves posibles
  static int? _extractInt(
    Map<String, dynamic> json,
    List<String> keys, {
    int? defaultValue,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        return _parseInt(value);
      }
    }
    return defaultValue;
  }

  /// Extrae booleano desde cualquiera de las claves posibles
  static bool _extractBool(
    Map<String, dynamic> json,
    List<String> keys, {
    bool defaultValue = false,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      } else if (value is int) {
        return value != 0;
      } else if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
    }
    return defaultValue;
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }
}
