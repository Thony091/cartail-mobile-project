import '../../domain/entities/vehicle.dart';

abstract class VehicleDatasource {
  Future<List<Vehicle>> getVehicles();
  Future<Vehicle> getVehicleById(String id);
  Future<Vehicle> createVehicle(Vehicle vehicle);
  Future<Vehicle> updateVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String id);
}
