import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/data/models/isar_domain_models.dart';
import 'user_local_datasource.dart';

class UserLocalDatasourceImpl implements UserLocalDatasource {
  UserLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  @override
  Future<UserModel?> getByBackendId(String backendId) {
    return _isar.userModels.filter().backendIdEqualTo(backendId).findFirst();
  }

  @override
  Future<UserModel?> getByEmail(String email) {
    return _isar.userModels.filter().emailEqualTo(email).findFirst();
  }

  @override
  Future<List<UserModel>> getAll() {
    return _isar.userModels.where().sortByUpdatedAtDesc().findAll();
  }

  @override
  Future<List<UserModel>> getUnsynced() {
    return _isar.userModels.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<List<UserModel>> getUpdatedAfter(DateTime since) {
    return _isar.userModels.filter().updatedAtGreaterThan(since).findAll();
  }

  @override
  Future<void> upsert(UserModel model) async {
    await _isar.writeTxn(() async {
      await _isar.userModels.put(model);
    });
  }

  @override
  Future<void> deleteByBackendId(String backendId) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.userModels
          .filter()
          .backendIdEqualTo(backendId)
          .findFirst();
      if (existing == null) return;
      await _isar.userModels.delete(existing.id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.userModels.clear();
    });
  }
}
