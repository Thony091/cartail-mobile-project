import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../../services/data/errors/service_errors.dart';
import '../../domain/entities/reservation.dart';
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
        // 'Authorization': 'Bearer $accessToken'
        'Content-Type': 'application/json',
      },
    ),
  );

  @override
  Future<Reservation> createUpdateReservation(
    Map<String, dynamic> reservationSimilar,
  ) async {
    try {
      final data = _normalizeReservationPayload(
        Map<String, dynamic>.from(reservationSimilar),
      );
      final response = await dio.post('/reserva', data: data);

      final reserva = ReservationMapper.jsonToEntity(
        _extractData(response.data),
      );

      return reserva;
    } catch (e) {
      throw Exception('Error al crear la reserva');
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
      throw e;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Reservation>> getReservations() async {
    try {
      final response = await dio.get('/reserva');
      final List<Reservation> reservations = [];

      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is List) {
          for (final reservation in data) {
            if (reservation is Map<String, dynamic>) {
              reservations.add(ReservationMapper.jsonToEntity(reservation));
            }
          }
        }
      }
      return reservations;
    } catch (e) {
      throw Exception('Error al obtener las reservas');
    }
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  Map<String, dynamic> _normalizeReservationPayload(Map<String, dynamic> data) {
    data['patenteVehiculo'] = (data['patenteVehiculo'] ?? '').toString().trim();
    data['fecha'] = _normalizeDate(data['fecha']?.toString() ?? '');
    data['horaInicio'] = _normalizeTime(data['horaInicio']?.toString() ?? '');
    data['horaFinEstimada'] =
        _normalizeTime(data['horaFinEstimada']?.toString() ?? '');
    data['notasCliente'] = (data['notasCliente'] ?? '').toString();
    data['notasMecanico'] = (data['notasMecanico'] ?? '').toString();
    data['recordatorio'] = data['recordatorio'] ?? true;
    data['idEstado'] = _parseInt(data['idEstado'], defaultValue: 1);
    data['idServicio'] = _parseInt(data['idServicio'], defaultValue: 1);
    data['idCliente'] = _parseInt(data['idCliente'], defaultValue: 1);
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
