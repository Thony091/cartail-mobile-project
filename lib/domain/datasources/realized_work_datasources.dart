import "../domain.dart";

abstract class RealizedWorkDatasource {

  Future<List<Works>> getRealizedWorks( );
  Future<Works> getRealizedWorkById( String id );
  Future<Works> createUpdateWorks( Map<String, dynamic> worksSimilar );
  Future<void> deleteWork( String id );

}