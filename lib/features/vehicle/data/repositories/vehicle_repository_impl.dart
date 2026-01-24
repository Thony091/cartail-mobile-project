import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_datasource.dart';

class VehicleRepositoryImpl extends VehicleRepository {
  final VehicleDatasource datasource;

  VehicleRepositoryImpl(this.datasource);

  @override
  Future<List<Vehicle>> getVehicles() {
    return datasource.getVehicles();
  }

  @override
  Future<Vehicle> getVehicleById(String id) {
    return datasource.getVehicleById(id);
  }

  @override
  Future<Vehicle> createUpdateVehicle(Map<String, dynamic> vehicleSimilar) {
    return datasource.createUpdateVehicle(vehicleSimilar);
  }

  @override
  Future<void> deleteVehicle(String id) {
    return datasource.deleteVehicle(id);
  }
}
