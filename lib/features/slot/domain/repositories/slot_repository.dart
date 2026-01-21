import '../entities/slot.dart';

abstract class SlotRepository {
  Future<List<Slot>> getSlots();
  Future<List<Slot>> getSlotsByService(String serviceId);
  Future<List<Slot>> getAvailableSlots(DateTime date);
  Future<Slot> getSlotById(int id);
  Future<Slot> createSlot(Slot slot);
  Future<Slot> updateSlot(Slot slot);
  Future<void> deleteSlot(int id);
}
