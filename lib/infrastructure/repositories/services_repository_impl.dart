
import '../../domain/domain.dart';

class ServicesRepositoryImpl extends ServicesRepository {

  final ServicesDatasource servicesDatasource;

  ServicesRepositoryImpl(this.servicesDatasource);

  @override
  Future<Services> createUpdateService(Map<String, dynamic> serviceSimilar) {
    return servicesDatasource.createUpdateService( serviceSimilar );
  }
  
  @override
  Future<void> deleteService(String id) {
    return servicesDatasource.deleteService(id);
  }
  
  @override
  Future<List<Services>> getServices() {
    return servicesDatasource.getServices();
  }
  
  @override
  Future<Services> getServiceById(String id) {
    return servicesDatasource.getServiceById(id);
  }
}
 