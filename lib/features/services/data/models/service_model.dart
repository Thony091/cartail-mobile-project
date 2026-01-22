import '../../domain/entities/services.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final int minPrice;
  final int maxPrice;
  final int durationMinutes;
  final bool requiresReservation;
  final bool isActive;
  final List<String> images;
  final int? categoryId;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.durationMinutes,
    required this.requiresReservation,
    required this.isActive,
    required this.images,
    this.categoryId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['nombre'] as String? ?? json['name'] as String? ?? '',
      description: json['descripcion'] as String? ?? json['description'] as String? ?? '',
      minPrice: _parseInt(json['precio_min'] ?? json['minPrice'], defaultValue: 0),
      maxPrice: _parseInt(json['precio_max'] ?? json['maxPrice'], defaultValue: 0),
      durationMinutes: json['duracion_minutos'] != null
          ? _parseInt(json['duracion_minutos'])
          : 0,
      requiresReservation: json['requiere_reserva'] as bool? ?? false,
      images: _readImages(json),
      isActive: json['activo'] as bool? ?? json['isActive'] as bool? ?? true,
      categoryId: json['id_categoria'] != null
          ? _parseInt(json['id_categoria'])
          : null,
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

  static List<String> _readImages(Map<String, dynamic> json) {
    final images = <String>[];
    if (json['images'] is List) {
      images.addAll(List<String>.from(json['images']));
    } else if (json['imagen'] is String && (json['imagen'] as String).isNotEmpty) {
      images.add(json['imagen'] as String);
    }

    return images.map((image) {
      if (image.startsWith('http') || image.startsWith('https')) return image;
      return 'https://ar-detailing.images.prod.s3.amazonaws.com/$image';
    }).toList();
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'nombre': name,
      'descripcion': description,
      'precio_min': minPrice,
      'precio_max': maxPrice,
      'activo': isActive,
      'imagen': images.isNotEmpty ? images.first : '',
      'requiere_reserva': requiresReservation,
    };

    if (durationMinutes != 0) {
      json['duracion_minutos'] = durationMinutes;
    }
    if (categoryId != null) {
      json['id_categoria'] = categoryId!;
    }

    return json;
  }

  Services toEntity() {
    return Services(
      id: id,
      name: name,
      description: description,
      minPrice: minPrice,
      maxPrice: maxPrice,
      durationMinutes: durationMinutes,
      requiresReservation: requiresReservation,
      images: images,
      isActive: isActive,
      categoryId: categoryId,
    );
  }

  factory ServiceModel.fromEntity(Services service) {
    return ServiceModel(
      id: service.id,
      name: service.name,
      description: service.description,
      minPrice: service.minPrice,
      maxPrice: service.maxPrice,
      durationMinutes: service.durationMinutes,
      requiresReservation: service.requiresReservation,
      images: service.images,
      isActive: service.isActive,
      categoryId: service.categoryId,
    );
  }
}
