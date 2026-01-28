import '../../../../shared/data/models/isar_domain_models.dart';

abstract class UserLocalDatasource {
  Future<UserModel?> getByBackendId(String backendId);
  Future<UserModel?> getByEmail(String email);
  Future<List<UserModel>> getAll();
  Future<List<UserModel>> getUnsynced();
  Future<List<UserModel>> getUpdatedAfter(DateTime since);
  Future<void> upsert(UserModel model);
  Future<void> deleteByBackendId(String backendId);
  Future<void> clear();
}
