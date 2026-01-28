import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/data/models/isar_domain_models.dart';
import 'slot_local_datasource.dart';

class SlotLocalDatasourceImpl implements SlotLocalDatasource {
  SlotLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  @override
  Future<SlotModel?> getByBackendId(String backendId) {
    return _isar.slotModels.filter().backendIdEqualTo(backendId).findFirst();
  }

  @override
  Future<List<SlotModel>> getByDate(String date) {
    return _isar.slotModels.filter().dateEqualTo(date).findAll();
  }

  @override
  Future<List<SlotModel>> getAll() {
    return _isar.slotModels.where().sortByUpdatedAtDesc().findAll();
  }

  @override
  Future<List<SlotModel>> getUnsynced() {
    return _isar.slotModels.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<List<SlotModel>> getUpdatedAfter(DateTime since) {
    return _isar.slotModels
        .filter()
        .updatedAtGreaterThan(since)
        .findAll();
  }

  @override
  Future<void> upsert(SlotModel model) async {
    await _isar.writeTxn(() async {
      await _isar.slotModels.put(model);
      if (model.service.value != null) {
        await model.service.save();
      }
    });
  }

  @override
  Future<void> deleteByBackendId(String backendId) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.slotModels
          .filter()
          .backendIdEqualTo(backendId)
          .findFirst();
      if (existing == null) return;
      await _isar.slotModels.delete(existing.id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.slotModels.clear();
    });
  }
}
