import '../../../../shared/data/models/isar_domain_models.dart';

abstract class ServiceLocalDatasource {
  Future<ServiceModel?> getByBackendId(String backendId);
  Future<List<ServiceModel>> getByName(String name);
  Future<List<ServiceModel>> getAll();
  Future<List<ServiceModel>> getUnsynced();
  Future<List<ServiceModel>> getUpdatedAfter(DateTime since);
  Future<void> upsert(ServiceModel model);
  Future<void> deleteByBackendId(String backendId);
  Future<void> clear();
}
