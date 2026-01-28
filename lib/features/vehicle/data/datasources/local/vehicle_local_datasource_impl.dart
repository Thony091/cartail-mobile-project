import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/data/models/isar_domain_models.dart';
import 'vehicle_local_datasource.dart';

class VehicleLocalDatasourceImpl implements VehicleLocalDatasource {
  VehicleLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  @override
  Future<VehicleModel?> getByBackendId(String backendId) {
    return _isar.vehicleModels
        .filter()
        .backendIdEqualTo(backendId)
        .findFirst();
  }

  @override
  Future<List<VehicleModel>> getByBrand(String brand) {
    return _isar.vehicleModels.filter().brandEqualTo(brand).findAll();
  }

  @override
  Future<List<VehicleModel>> getAll() {
    return _isar.vehicleModels.where().sortByUpdatedAtDesc().findAll();
  }

  @override
  Future<List<VehicleModel>> getUnsynced() {
    return _isar.vehicleModels.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<List<VehicleModel>> getUpdatedAfter(DateTime since) {
    return _isar.vehicleModels
        .filter()
        .updatedAtGreaterThan(since)
        .findAll();
  }

  @override
  Future<void> upsert(VehicleModel model) async {
    await _isar.writeTxn(() async {
      await _isar.vehicleModels.put(model);
    });
  }

  @override
  Future<void> deleteByBackendId(String backendId) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.vehicleModels
          .filter()
          .backendIdEqualTo(backendId)
          .findFirst();
      if (existing == null) return;
      await _isar.vehicleModels.delete(existing.id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.vehicleModels.clear();
    });
  }
}
