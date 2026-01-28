import '../../../../shared/data/models/isar_domain_models.dart';

abstract class VehicleLocalDatasource {
  Future<VehicleModel?> getByBackendId(String backendId);
  Future<List<VehicleModel>> getByBrand(String brand);
  Future<List<VehicleModel>> getAll();
  Future<List<VehicleModel>> getUnsynced();
  Future<List<VehicleModel>> getUpdatedAfter(DateTime since);
  Future<void> upsert(VehicleModel model);
  Future<void> deleteByBackendId(String backendId);
  Future<void> clear();
}
