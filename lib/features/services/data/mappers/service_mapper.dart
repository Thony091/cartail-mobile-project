
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
      // Filtra URLs vacías y convierte a strings
      final imagesList = (json['images'] as List)
          .map((img) => img?.toString() ?? '')
          .where((img) => img.trim().isNotEmpty)
          .toList();
      images.addAll(imagesList);
    } else if (json['imagen'] is String && (json['imagen'] as String).trim().isNotEmpty) {
      images.add((json['imagen'] as String).trim());
    }

    return images.map((image) {
      final trimmed = image.trim();
      // Si ya es una URL HTTP/HTTPS, usa tal cual
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }
      // Si está vacío después de trim, no la agregues
      if (trimmed.isEmpty) return '';
      // Construye URL de S3 para rutas relativas
      return 'https://ar-detailing.images.prod.s3.amazonaws.com/$trimmed';
    }).where((img) => img.isNotEmpty).toList();
  }
}
