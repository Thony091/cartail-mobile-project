import '../../domain/entities/vehicle.dart';

abstract class VehicleDatasource {
  Future<List<Vehicle>> getVehicles();
  Future<Vehicle> getVehicleById(String id);
  Future<Vehicle> createUpdateVehicle(Map<String, dynamic> vehicleSimilar);
  Future<void> deleteVehicle(String id);
}
