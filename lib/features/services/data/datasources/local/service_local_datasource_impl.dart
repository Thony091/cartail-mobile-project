import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/data/models/isar_domain_models.dart';
import 'service_local_datasource.dart';

class ServiceLocalDatasourceImpl implements ServiceLocalDatasource {
  ServiceLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  @override
  Future<ServiceModel?> getByBackendId(String backendId) {
    return _isar.serviceModels
        .filter()
        .backendIdEqualTo(backendId)
        .findFirst();
  }

  @override
  Future<List<ServiceModel>> getByName(String name) {
    return _isar.serviceModels.filter().nameEqualTo(name).findAll();
  }

  @override
  Future<List<ServiceModel>> getAll() {
    return _isar.serviceModels.where().sortByUpdatedAtDesc().findAll();
  }

  @override
  Future<List<ServiceModel>> getUnsynced() {
    return _isar.serviceModels.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<List<ServiceModel>> getUpdatedAfter(DateTime since) {
    return _isar.serviceModels
        .filter()
        .updatedAtGreaterThan(since)
        .findAll();
  }

  @override
  Future<void> upsert(ServiceModel model) async {
    await _isar.writeTxn(() async {
      // Si el modelo tiene backendId, buscar si ya existe en la BD
      if (model.backendId.isNotEmpty) {
        final existing = await _isar.serviceModels
            .filter()
            .backendIdEqualTo(model.backendId)
            .findFirst();

        if (existing != null) {
          // Copiar el ID local del registro existente para actualizar
          model.id = existing.id;
        }
      }

      await _isar.serviceModels.put(model);
    });
  }

  @override
  Future<void> deleteByBackendId(String backendId) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.serviceModels
          .filter()
          .backendIdEqualTo(backendId)
          .findFirst();
      if (existing == null) return;
      await _isar.serviceModels.delete(existing.id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.serviceModels.clear();
    });
  }
}
