import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../config/config.dart';
import '../../../services/data/errors/service_errors.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_payment_init.dart';
import '../mappers/reservation_mapper.dart';
import 'reservation_datasources.dart';

class ReservationDatasourceImpl extends ReservationDatasource {
  late final Dio dio;
  final String accessToken;

  ReservationDatasourceImpl({required this.accessToken})
    : dio = Dio(
        BaseOptions(
      baseUrl: Enviroment.baseUrl,
      headers: {
        // 'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
        // 'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      // Acepta códigos 2xx, 307 (redirección temporal para pago) y no lanza excepción
      validateStatus: (status) {
        return status != null && status < 400;
      },
      )
    ) {
      _attachAuthHeader();
    }

  void _attachAuthHeader() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = accessToken.isNotEmpty ? accessToken : '';
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
      ),
    );
  }

  @override
  Future<Reservation> createUpdateReservation(
    Map<String, dynamic> reservationSimilar,
  ) async {
    try {
      final data = _normalizeReservationPayload(
        Map<String, dynamic>.from(reservationSimilar),
      );
      final response = await dio.post('/reserva', data: data);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'createUpdateReservation failed with status ${response.statusCode}',
        );
      }

      final payload = _extractData(response.data);
      if (payload is Map<String, dynamic>) {
        return ReservationMapper.jsonToEntity(payload);
      }
      throw Exception('createUpdateReservation returned empty payload');
    } catch (e) {
      throw Exception('Error al crear la reserva');
    }
  }

  @override
  Future<ReservationPaymentInit> pagarReserva(
    Map<String, dynamic> reservationSimilar,
  ) async {
    try {
      final data = _normalizeReservationPayload(
        Map<String, dynamic>.from(reservationSimilar),
      );
      final response = await dio.post(
        '/reserva.pagar',
        data: data,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      final redirectUrl = _extractRedirectUrlFromResponse(response);
      if (redirectUrl.isNotEmpty) {
        return ReservationPaymentInit(paymentUrl: redirectUrl);
      }

      final payload = _extractData(response.data);

      if (payload is Map<String, dynamic>) {
        final paymentUrl = _extractPaymentUrl(payload);
        if (paymentUrl.isEmpty) {
          throw Exception('Respuesta de pago inválida: falta paymentUrl');
        }
        return ReservationPaymentInit(
          paymentUrl: paymentUrl,
          reservationBackendId: _stringOrNull(
            payload['reservationBackendId'] ??
                payload['reservationId'] ??
                payload['idReserva'] ??
                payload['id_reserva'],
          ),
          paymentId: _stringOrNull(
            payload['paymentId'] ??
                payload['payment_id'] ??
                payload['idPago'] ??
                payload['id_pago'],
          ),
        );
      }

      throw Exception('Respuesta de pago inválida: formato de respuesta incorrecto');
    } on DioException catch (e) {
      throw Exception('Error de conexión al iniciar pago: ${e.message}');
    } catch (e) {
      throw Exception('Error al iniciar el pago de la reserva: $e');
    }
  }

  @override
  Future<void> deleteReservation(String id) async {
    try {
      await dio.delete('/reserva/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Reservation> getReservationById(String id) async {
    try {
      final response = await dio.get('/reserva/$id');
      Reservation reservation = Reservation(
        id: '',
        name: '',
        rut: '',
        email: '',
        reservationDate: '',
        reservationTime: '',
        serviceName: '',
        idTransaccion: '',
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          reservation = ReservationMapper.jsonToEntity(data);
        }
      }
      return reservation;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ServiceNotFound();
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Reservation>> getReservations() async {
    try {
      if (kDebugMode) {
        print('\x1B[36m');
        print('═══════════════════════════════════════════════════════');
        print('[ReservationDatasource] 🔵 INICIANDO: GET /reserva');
        print('═══════════════════════════════════════════════════════');
        print('\x1B[0m');
      }

      final response = await dio.get('/reserva');

      if (kDebugMode) {
        print('\x1B[36m');
        print('Status Code: ${response.statusCode}');
        print('Response: ${response.data}');
        print('\x1B[0m');
      }

      final List<Reservation> reservations = [];

      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is List) {
          if (kDebugMode) {
            print('\x1B[36m[ReservationDatasource] Total items en lista: ${data.length}\x1B[0m');
          }

          for (int i = 0; i < data.length; i++) {
            final reservation = data[i];
            if (reservation is Map<String, dynamic>) {
              try {
                reservations.add(ReservationMapper.jsonToEntity(reservation));
              } catch (e) {
                if (kDebugMode) {
                  print('\x1B[31m');
                  print('ERROR mapeando reserva #$i: $e');
                  print('JSON: $reservation');
                  print('\x1B[0m');
                }
                // Continúa con la siguiente reserva en lugar de fallar completamente
              }
            }
          }
        }
      }

      if (kDebugMode) {
        print('\x1B[32m');
        print('═══════════════════════════════════════════════════════');
        print('[ReservationDatasource] ✅ Reservas obtenidas: ${reservations.length}');
        print('═══════════════════════════════════════════════════════');
        print('\x1B[0m');
      }

      return reservations;
    } catch (e) {
      if (kDebugMode) {
        print('\x1B[31m');
        print('[ReservationDatasource] ❌ ERROR al obtener reservas: $e');
        print('\x1B[0m');
      }
      throw Exception('Error al obtener las reservas: $e');
    }
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  String _extractPaymentUrl(Map<String, dynamic> payload) {
    return (payload['paymentUrl'] ??
            payload['payment_url'] ??
            payload['urlPago'] ??
            payload['url_pago'] ??
            payload['url'] ??
            '')
        .toString()
        .trim();
  }

  String _extractRedirectUrlFromResponse(Response response) {
    if (response.statusCode == 307 || response.statusCode == 302) {
      final location = response.headers.value('location');
      if (location != null && location.trim().isNotEmpty) {
        return location.trim();
      }
    }

    final raw = response.data;
    if (raw is String) {
      final match = RegExp(r'https?://\S+').firstMatch(raw);
      if (match != null) {
        return match.group(0)?.trim() ?? '';
      }
    }
    return '';
  }

  String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString().trim();
    return parsed.isEmpty ? null : parsed;
  }

  Map<String, dynamic> _normalizeReservationPayload(Map<String, dynamic> data) {
    data['patenteVehiculo'] = (data['patenteVehiculo'] ?? '').toString().trim();
    if (data.containsKey('fecha')) {
      data['fecha'] = _normalizeDate(data['fecha']?.toString() ?? '');
    }
    if (data.containsKey('horaInicio')) {
      data['horaInicio'] = _normalizeTime(data['horaInicio']?.toString() ?? '');
    }
    if (data.containsKey('horaFinEstimada')) {
      data['horaFinEstimada'] =
          _normalizeTime(data['horaFinEstimada']?.toString() ?? '');
    }
    data['notasCliente'] = (data['notasCliente'] ?? '').toString();
    data['notasMecanico'] = (data['notasMecanico'] ?? '').toString();
    data['recordatorio'] = data['recordatorio'] ?? true;
    data['idEstado'] = _parseInt(data['idEstado'], defaultValue: 1);
    data['idServicio'] = _parseInt(data['idServicio'], defaultValue: 1);
    if (data.containsKey('idCliente')) {
      final rawClientId = data['idCliente'];
      if (rawClientId == null || rawClientId.toString().trim().isEmpty) {
        data['idCliente'] = null;
      } else {
        data['idCliente'] = _parseInt(rawClientId, defaultValue: 1);
      }
    }
    if (data.containsKey('idImportancia')) {
      data['idImportancia'] = _parseInt(data['idImportancia'], defaultValue: 1);
    }
    if (data.containsKey('idUrgencia')) {
      data['idUrgencia'] = _parseInt(data['idUrgencia'], defaultValue: 1);
    }
    if (data.containsKey('idSlot')) {
      data['idSlot'] = _parseInt(data['idSlot'], defaultValue: 0);
    }
    return data;
  }

  String _normalizeDate(String value) {
    if (value.isEmpty) return value;
    if (value.contains('T')) return value;
    if (value.length >= 10) return value.substring(0, 10);
    return value;
  }

  String _normalizeTime(String value) {
    if (value.isEmpty) return value;
    final parts = value.split(':');
    if (parts.length == 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
    }
    if (parts.length == 3) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${parts[2].padLeft(2, '0')}';
    }
    return value;
  }

  int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }
}
