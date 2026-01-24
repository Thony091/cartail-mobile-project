import '../../domain/entities/vehicle.dart';

class VehicleMapper {
  static Vehicle jsonToEntity(Map<String, dynamic> json) => Vehicle(
    id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
    brand: json['marca'] as String? ?? '',
    model: json['modelo'] as String? ?? '',
    year: json['anio']?.toString() ?? '',
    trim: json['trim'] as String? ?? '',
  );

  static Map<String, dynamic> entityToJson(Vehicle vehicle) => {
    'id': vehicle.id,
    'marca': vehicle.brand,
    'modelo': vehicle.model,
    'anio': vehicle.year,
    'trim': vehicle.trim,
  };
}
