import '../../../../shared/data/models/isar_domain_models.dart';

abstract class SlotLocalDatasource {
  Future<SlotModel?> getByBackendId(String backendId);
  Future<List<SlotModel>> getByDate(String date);
  Future<List<SlotModel>> getAll();
  Future<List<SlotModel>> getUnsynced();
  Future<List<SlotModel>> getUpdatedAfter(DateTime since);
  Future<void> upsert(SlotModel model);
  Future<void> deleteByBackendId(String backendId);
  Future<void> clear();
}
