import '../../domain/entities/slot.dart';
import '../../domain/repositories/slot_repository.dart';
import '../datasources/slot_datasource.dart';

class SlotRepositoryImpl extends SlotRepository {
  final SlotDatasource datasource;

  SlotRepositoryImpl(this.datasource);

  @override
  Future<List<Slot>> getSlots() {
    return datasource.getSlots();
  }

  @override
  Future<List<Slot>> getSlotsByService(String serviceId) {
    return datasource.getSlotsByService(serviceId);
  }

  @override
  Future<List<Slot>> getAvailableSlots(DateTime date) {
    return datasource.getAvailableSlots(date);
  }

  @override
  Future<Slot> getSlotById(int id) {
    return datasource.getSlotById(id);
  }

  @override
  Future<Slot> createSlot(Slot slot) {
    return datasource.createSlot(slot);
  }

  @override
  Future<Slot> updateSlot(Slot slot) {
    return datasource.updateSlot(slot);
  }

  @override
  Future<void> deleteSlot(int id) {
    return datasource.deleteSlot(id);
  }
}
