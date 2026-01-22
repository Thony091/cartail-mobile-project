
import '../../domain/entities/services.dart';

class ServiceMapper {

  static jsonToEntity( Map<String, dynamic> json) => Services(
    id: json['id'].toString(),
    name: json['nombre'] ?? json['name'] ?? '',
    description: json['descripcion'] ?? json['description'] ?? '',
    minPrice: _parseInt(json['precio_min'] ?? json['minPrice'], defaultValue: 0),
    maxPrice: _parseInt(json['precio_max'] ?? json['maxPrice'], defaultValue: 0),
    durationMinutes: json['duracion_minutos'] != null
        ? _parseInt(json['duracion_minutos'])
        : 0,
    requiresReservation: json['requiere_reserva'] ?? false,
    images: _readImages(json),
    isActive: json['activo'] ?? json['isActive'] ?? true,
    categoryId: json['id_categoria'] != null
        ? _parseInt(json['id_categoria'])
        : null,
  );

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
}
