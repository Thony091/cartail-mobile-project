import '../../domain/entities/slot.dart';
import '../../domain/repositories/slot_repository.dart';
import '../datasources/slot_datasource.dart';

class SlotRepositoryImpl extends SlotRepository {
  SlotRepositoryImpl({
    required SlotDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final SlotDatasource _remoteDatasource;

  @override
  Future<List<Slot>> getSlots() {
    return _remoteDatasource.getSlots();
  }

  @override
  Future<List<Slot>> getSlotsByService(String serviceId) {
    return _remoteDatasource.getSlotsByService(serviceId);
  }

  @override
  Future<List<Slot>> getAvailableSlots(DateTime date) {
    return _remoteDatasource.getAvailableSlots(date);
  }

  @override
  Future<Slot> getSlotById(int id) {
    return _remoteDatasource.getSlotById(id);
  }

  @override
  Future<Slot> createSlot(Slot slot) {
    return _remoteDatasource.createSlot(slot);
  }

  @override
  Future<Slot> updateSlot(Slot slot) {
    return _remoteDatasource.updateSlot(slot);
  }

  @override
  Future<void> deleteSlot(int id) {
    return _remoteDatasource.deleteSlot(id);
  }
}
