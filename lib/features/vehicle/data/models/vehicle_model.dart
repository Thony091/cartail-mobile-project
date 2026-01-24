import '../../domain/entities/vehicle.dart';

class VehicleModel {
  final int id;
  final String brand;
  final String model;
  final String year;
  final String trim;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.trim,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      brand: json['marca'] as String? ?? '',
      model: json['modelo'] as String? ?? '',
      year: json['anio']?.toString() ?? '',
      trim: json['trim'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca': brand,
      'modelo': model,
      'anio': year,
      'trim': trim,
    };
  }

  Vehicle toEntity() {
    return Vehicle(
      id: id,
      brand: brand,
      model: model,
      year: year,
      trim: trim,
    );
  }

  factory VehicleModel.fromEntity(Vehicle vehicle) {
    return VehicleModel(
      id: vehicle.id,
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.year,
      trim: vehicle.trim,
    );
  }
}
