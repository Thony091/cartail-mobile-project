import '../domain.dart';

abstract class RealizedWorkRepository{
  
  Future<List<Works>> getRealizedWorks( );
  Future<Works> getRealizedWorkById( String id );
  Future<Works> createUpdateWorks( Map<String, dynamic> worksSimilar );
  Future<void> deleteWork( String id );
  
}