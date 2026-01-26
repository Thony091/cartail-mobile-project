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
      headers: {
        'Content-Type': 'application/json',
      }
    )
  );

  @override
  Future<List<Slot>> getSlots() async {
    try {
      final response = await dio.get('/slot');
      final List<Slot> slots = [];
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          var slotsData = data['data'];
          if (slotsData is List) {
            for (final slot in slotsData) {
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
          slot = SlotMapper.jsonToEntity(data['data']);
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
      final slotData = SlotMapper.entityToJson(slot);
      slotData.remove('id');

      final response = await dio.post(
        '/slot',
        data: slotData,
      );

      Slot newSlot = Slot(
        id: 0,
        date: '',
        startTime: '',
        endTime: '',
        serviceId: 0,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          newSlot = SlotMapper.jsonToEntity(data['data']);
        }
      }
      return newSlot;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Slot> updateSlot(Slot slot) async {
    try {
      final slotData = SlotMapper.entityToJson(slot);
      final int slotId = slotData['id'];
      slotData.remove('id');

      final response = await dio.patch(
        '/slot/$slotId',
        data: slotData,
      );

      Slot updatedSlot = Slot(
        id: 0,
        date: '',
        startTime: '',
        endTime: '',
        serviceId: 0,
      );
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          updatedSlot = SlotMapper.jsonToEntity(data['data']);
        }
      }
      return updatedSlot;
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
}
