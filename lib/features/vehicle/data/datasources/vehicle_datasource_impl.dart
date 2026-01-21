import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/vehicle.dart';
import '../errors/vehicle_errors.dart';
import '../mappers/vehicle_mapper.dart';
import 'vehicle_datasource.dart';

class VehicleDatasourceImpl extends VehicleDatasource {
  late final Dio dio;
  final String accessToken;

  VehicleDatasourceImpl({
    required this.accessToken
  }) : dio = Dio(
    BaseOptions(
      baseUrl: Enviroment.baseUrl,
      headers: {
        'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      }
    )
  );

  @override
  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await dio.get('/vehicle');
      final List<Vehicle> vehicles = [];
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          var vehiclesData = data['data'];
          if (vehiclesData is List) {
            for (final vehicle in vehiclesData) {
              vehicles.add(VehicleMapper.jsonToEntity(vehicle));
            }
          }
        }
      }
      return vehicles;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Future<Vehicle> getVehicleById(String id) async {
    try {
      final response = await dio.get('/vehicle/$id');
      Vehicle vehicle = Vehicle(
        id: '', brand: '', model: '', year: ''
      );
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          vehicle = VehicleMapper.jsonToEntity(data['data']);
        }
      }
      return vehicle;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) throw VehicleNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      final vehicleData = VehicleMapper.entityToJson(vehicle);
      vehicleData.remove('id');

      final response = await dio.post(
        '/vehicle',
        data: vehicleData,
      );

      Vehicle newVehicle = Vehicle(
        id: '', brand: '', model: '', year: ''
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          newVehicle = VehicleMapper.jsonToEntity(data['data']);
        }
      }
      return newVehicle;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    try {
      final vehicleData = VehicleMapper.entityToJson(vehicle);
      final String vehicleId = vehicleData['id'];
      vehicleData.remove('id');

      final response = await dio.put(
        '/vehicle/$vehicleId',
        data: vehicleData,
      );

      Vehicle updatedVehicle = Vehicle(
        id: '', brand: '', model: '', year: ''
      );
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          updatedVehicle = VehicleMapper.jsonToEntity(data['data']);
        }
      }
      return updatedVehicle;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await dio.delete('/vehicle/$id');
    } catch (e) {
      throw Exception(e);
    }
  }
}
