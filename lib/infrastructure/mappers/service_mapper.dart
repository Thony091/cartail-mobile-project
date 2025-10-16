
import '../../domain/domain.dart';

class ServiceMapper {

  static jsonToEntity( Map<String, dynamic> json) => Services(
    id: json['id'].toString(), 
    name: json['name'] ?? '', 
    description: json['description'] ?? '', 
    minPrice: _parseInt(json['minPrice'], defaultValue: 0), 
    maxPrice: _parseInt(json['maxPrice'], defaultValue: 0), 
    images: json['images'] != null 
      ? List<String>.from(json['images'].map(
          (image) => (image.startsWith('http') || image.startsWith('https'))
            ? image
            : 'https://ar-detailing.images.prod.s3.amazonaws.com/$image'
        ))
      : [], 
    isActive: json['isActive'] ?? false,
  );

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }
}