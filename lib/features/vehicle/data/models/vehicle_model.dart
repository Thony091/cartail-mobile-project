import '../../domain/entities/vehicle.dart';

class VehicleModel {
  final String id;
  final String brand;
  final String model;
  final String year;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id']?.toString() ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
    };
  }

  Vehicle toEntity() {
    return Vehicle(
      id: id,
      brand: brand,
      model: model,
      year: year,
    );
  }

  factory VehicleModel.fromEntity(Vehicle vehicle) {
    return VehicleModel(
      id: vehicle.id,
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.year,
    );
  }
}
