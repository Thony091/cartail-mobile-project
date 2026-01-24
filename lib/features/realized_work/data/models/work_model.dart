import '../../domain/entities/works.dart';

class WorkModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String testimonial;
  final int rating;
  final bool isFeatured;
  final bool isActive;
  final String date;
  final int? vehicleModelId;
  final String beforeImage;
  final String afterImage;

  WorkModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.testimonial,
    required this.rating,
    required this.isFeatured,
    required this.isActive,
    required this.date,
    this.vehicleModelId,
    required this.beforeImage,
    required this.afterImage,
  });

  factory WorkModel.fromJson(Map<String, dynamic> json) {
    return WorkModel(
      id: json['id']?.toString() ?? '',
      name: json['titulo'] as String? ?? json['name'] as String? ?? '',
      description: json['descripcion'] as String? ?? json['description'] as String? ?? '',
      image: json['imagen_despues'] as String? ?? json['imagen_antes'] as String? ?? json['image'] as String? ?? '',
      testimonial: json['testimonio'] as String? ?? '',
      rating: _parseInt(json['calificacion']),
      isFeatured: json['destacado'] as bool? ?? false,
      isActive: json['activo'] as bool? ?? true,
      date: json['fecha'] as String? ?? '',
      vehicleModelId: json['id_modelo_vehiculo'] != null ? _parseInt(json['id_modelo_vehiculo']) : null,
      beforeImage: json['imagen_antes'] as String? ?? '',
      afterImage: json['imagen_despues'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': name,
      'descripcion': description,
      'testimonio': testimonial,
      'calificacion': rating,
      'destacado': isFeatured,
      'activo': isActive,
      'fecha': date,
      if (vehicleModelId != null) 'id_modelo_vehiculo': vehicleModelId,
      'imagen_antes': beforeImage,
      'imagen_despues': afterImage,
    };
  }

  Works toEntity() {
    return Works(
      id: id,
      name: name,
      description: description,
      image: image,
      testimonial: testimonial,
      rating: rating,
      isFeatured: isFeatured,
      isActive: isActive,
      date: date,
      vehicleModelId: vehicleModelId,
      beforeImage: beforeImage,
      afterImage: afterImage,
    );
  }

  factory WorkModel.fromEntity(Works work) {
    return WorkModel(
      id: work.id,
      name: work.name,
      description: work.description,
      image: work.image,
      testimonial: work.testimonial,
      rating: work.rating,
      isFeatured: work.isFeatured,
      isActive: work.isActive,
      date: work.date,
      vehicleModelId: work.vehicleModelId,
      beforeImage: work.beforeImage,
      afterImage: work.afterImage,
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }
}
