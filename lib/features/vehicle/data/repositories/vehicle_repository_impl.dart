import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_datasource.dart';

class VehicleRepositoryImpl extends VehicleRepository {
  VehicleRepositoryImpl({
    required VehicleDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final VehicleDatasource _remoteDatasource;

  @override
  Future<List<Vehicle>> getVehicles() {
    return _remoteDatasource.getVehicles();
  }

  @override
  Future<Vehicle> getVehicleById(String id) {
    return _remoteDatasource.getVehicleById(id);
  }

  @override
  Future<Vehicle> createUpdateVehicle(Map<String, dynamic> vehicleSimilar) {
    return _remoteDatasource.createUpdateVehicle(vehicleSimilar);
  }

  @override
  Future<void> deleteVehicle(String id) {
    return _remoteDatasource.deleteVehicle(id);
  }
}
