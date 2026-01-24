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
      final response = await dio.get('/modelo-vehiculo');
      final List<Vehicle> vehicles = [];
      final data = _extractData(response.data);
      if (data is List) {
        for (final vehicle in data) {
          if (vehicle is Map<String, dynamic>) {
            vehicles.add(VehicleMapper.jsonToEntity(vehicle));
          }
        }
      }
      return vehicles;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Vehicle> getVehicleById(String id) async {
    try {
      final response = await dio.get('/modelo-vehiculo/$id');
      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return VehicleMapper.jsonToEntity(data);
      }
      return _emptyVehicle();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) throw VehicleNotFound();
      throw e;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Vehicle> createUpdateVehicle(Map<String, dynamic> vehicleSimilar) async {
    try {
      final dataPayload = Map<String, dynamic>.from(vehicleSimilar);
      final String? vehicleId = dataPayload['id']?.toString();
      final String method = (vehicleId == null) ? 'POST' : 'PATCH';
      final String url = (vehicleId == null)
          ? '/modelo-vehiculo'
          : '/modelo-vehiculo/$vehicleId';
      if (vehicleId == null) {
        dataPayload.remove('id');
      }

      final response = await dio.request(
        url,
        data: dataPayload,
        options: Options(method: method),
      );

      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return VehicleMapper.jsonToEntity(data);
      }
      return _emptyVehicle();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await dio.delete('/modelo-vehiculo/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  Vehicle _emptyVehicle() {
    return Vehicle(
      id: 0,
      brand: '',
      model: '',
      year: '',
      trim: '',
    );
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
