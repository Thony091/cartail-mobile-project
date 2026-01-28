import '../../domain/entities/services.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_datasources.dart';

class ServicesRepositoryImpl extends ServicesRepository {
  ServicesRepositoryImpl({
    required ServicesDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final ServicesDatasource _remoteDatasource;

  @override
  Future<List<Services>> getServices() {
    return _remoteDatasource.getServices();
  }

  @override
  Future<Services> getServiceById(String id) {
    return _remoteDatasource.getServiceById(id);
  }

  @override
  Future<Services> createUpdateService(Map<String, dynamic> serviceSimilar) {
    return _remoteDatasource.createUpdateService(serviceSimilar);
  }

  @override
  Future<void> deleteService(String id) {
    return _remoteDatasource.deleteService(id);
  }
}
 
