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
  Future<Vehicle> createVehicle(Vehicle vehicle) {
    return datasource.createVehicle(vehicle);
  }

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) {
    return datasource.updateVehicle(vehicle);
  }

  @override
  Future<void> deleteVehicle(String id) {
    return datasource.deleteVehicle(id);
  }
}
