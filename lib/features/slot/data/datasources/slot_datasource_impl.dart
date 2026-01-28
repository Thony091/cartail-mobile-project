import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/slot.dart';
import '../errors/slot_errors.dart';
import '../mappers/slot_mapper.dart';
import 'slot_datasource.dart';

class SlotDatasourceImpl extends SlotDatasource {
  late final Dio dio;
  final String accessToken;

  SlotDatasourceImpl({
    required this.accessToken
  }) : dio = Dio(
      BaseOptions(
        baseUrl: Enviroment.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        }
      ),
    ) {
    _attachAuthHeader();
  }

  void _attachAuthHeader() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = accessToken.isNotEmpty ? accessToken : '';
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  @override
  Future<List<Slot>> getSlots() async {
    try {
      final response = await dio.get('/slot');
      final List<Slot> slots = [];
      if (response.statusCode == 200) {
        var data = response.data;
        var slotsData = data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          slotsData = data['data'];
        }
        if (slotsData is List) {
          for (final slot in slotsData) {
            if (slot is Map<String, dynamic>) {
              slots.add(SlotMapper.jsonToEntity(slot));
            }
          }
        }
      }
      return slots;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Future<List<Slot>> getSlotsByService(String serviceId) async {
    try {
      final slots = await getSlots();
      final serviceIdParsed = int.tryParse(serviceId);
      return slots.where((slot) => slot.serviceId == serviceIdParsed).toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Future<List<Slot>> getAvailableSlots(DateTime date) async {
    try {
      final slots = await getSlots();
      final dateKey = date.toIso8601String().substring(0, 10);
      return slots
          .where((slot) => slot.isAvailable && slot.date.startsWith(dateKey))
          .toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Future<Slot> getSlotById(int id) async {
    try {
      final response = await dio.get('/slot/$id');
      Slot slot = Slot(
        id: 0,
        date: '',
        startTime: '',
        endTime: '',
        serviceId: 0,
      );
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          data = data['data'];
        }
        if (data is Map<String, dynamic>) {
          slot = SlotMapper.jsonToEntity(data);
        }
      }
      return slot;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) throw SlotNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Slot> createSlot(Slot slot) async {
    try {
      final response = await dio.post(
        '/slot',
        data: _slotPayload(slot, includeId: false),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('createSlot failed with status ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return SlotMapper.jsonToEntity(data['data']);
      }
      throw Exception('createSlot returned empty payload');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Slot> updateSlot(Slot slot) async {
    try {
      final payload = _slotPayload(slot, includeId: true);
      final int slotId = payload['id'] as int;

      final response = await dio.patch(
        '/slot/$slotId',
        data: payload,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('updateSlot failed with status ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return SlotMapper.jsonToEntity(data['data']);
      }
      throw Exception('updateSlot returned empty payload');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteSlot(int id) async {
    try {
      await dio.delete('/slot/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  Map<String, dynamic> _slotPayload(Slot slot, {required bool includeId}) {
    final payload = <String, dynamic>{
      'idServicio': slot.serviceId,
      if (slot.reservationId != null) 'idReserva': slot.reservationId,
    };

    final inicio = _buildIsoDateTime(slot.date, slot.startTime);
    final fin = _buildIsoDateTime(slot.date, slot.endTime);

    if (inicio != null) payload['inicio'] = inicio;
    if (fin != null) payload['fin'] = fin;
    payload['fecha'] = slot.date;
    payload['horaInicio'] = slot.startTime;
    payload['horaFin'] = slot.endTime;

    if (includeId && slot.id > 0) {
      payload['id'] = slot.id;
    }

    return payload;
  }

  String? _buildIsoDateTime(String date, String time) {
    final trimmedDate = date.trim();
    final trimmedTime = time.trim();
    if (trimmedDate.isEmpty || trimmedTime.isEmpty) {
      return null;
    }

    final dateParts = trimmedDate.split('-');
    if (dateParts.length != 3) return null;
    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);
    if (year == null || month == null || day == null) return null;

    final timeParts = trimmedTime.split(':');
    if (timeParts.length != 2) return null;
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return null;

    return DateTime.utc(year, month, day, hour, minute).toIso8601String();
  }
}
