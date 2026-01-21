
import '../../domain/entities/works.dart';
import '../../domain/repositories/realized_work_repository.dart';
import '../datasources/realized_work_datasources.dart';

class RealizedWorksRepositoryImpl extends RealizedWorkRepository {
  
  final RealizedWorkDatasource realizedWorkDatasource;

  RealizedWorksRepositoryImpl(this.realizedWorkDatasource);
  
  @override
  Future<Works> createUpdateWorks(Map<String, dynamic> worksSimilar) {
    return realizedWorkDatasource.createUpdateWorks(worksSimilar);
  }
  
  @override
  Future<void> deleteWork(String id) {
    return realizedWorkDatasource.deleteWork(id);
  }
  
  @override
  Future<Works> getRealizedWorkById(String id) {
    return realizedWorkDatasource.getRealizedWorkById(id);
  }
  
  @override
  Future<List<Works>> getRealizedWorks() {
    return realizedWorkDatasource.getRealizedWorks();
  }


}