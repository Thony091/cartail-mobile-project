import '../../domain/entities/services.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final int minPrice;
  final int maxPrice;
  final bool isActive;
  final List<String> images;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.images,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      minPrice: _parseInt(json['minPrice'], defaultValue: 0),
      maxPrice: _parseInt(json['maxPrice'], defaultValue: 0),
      images: json['images'] != null
        ? List<String>.from(json['images'].map(
            (image) => (image.startsWith('http') || image.startsWith('https'))
              ? image
              : 'https://ar-detailing.images.prod.s3.amazonaws.com/$image'
          ))
        : [],
      isActive: json['isActive'] as bool? ?? false,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'images': images,
      'isActive': isActive,
    };
  }

  Services toEntity() {
    return Services(
      id: id,
      name: name,
      description: description,
      minPrice: minPrice,
      maxPrice: maxPrice,
      images: images,
      isActive: isActive,
    );
  }

  factory ServiceModel.fromEntity(Services service) {
    return ServiceModel(
      id: service.id,
      name: service.name,
      description: service.description,
      minPrice: service.minPrice,
      maxPrice: service.maxPrice,
      images: service.images,
      isActive: service.isActive,
    );
  }
}
