import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getVehicles();
  Future<Vehicle> getVehicleById(String id);
  Future<Vehicle> createUpdateVehicle(Map<String, dynamic> vehicleSimilar);
  Future<void> deleteVehicle(String id);
}
