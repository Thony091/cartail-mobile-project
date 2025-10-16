import '../domain.dart';

abstract class ServicesRepository{

  Future<List<Services>> getServices( );
  Future<Services> getServiceById( String id );
  Future<Services> createUpdateService( Map<String, dynamic> serviceSimilar );
  Future<void> deleteService( String id );
}