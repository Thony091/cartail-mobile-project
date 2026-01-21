import '../../domain/entities/vehicle.dart';

class VehicleMapper {
  static Vehicle jsonToEntity(Map<String, dynamic> json) => Vehicle(
    id: json['id']?.toString() ?? '',
    brand: json['brand'] as String? ?? '',
    model: json['model'] as String? ?? '',
    year: json['year'] as String? ?? '',
  );

  static Map<String, dynamic> entityToJson(Vehicle vehicle) => {
    'id': vehicle.id,
    'brand': vehicle.brand,
    'model': vehicle.model,
    'year': vehicle.year,
  };
}
