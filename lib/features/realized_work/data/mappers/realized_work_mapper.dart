
import '../../domain/entities/works.dart';
// import '../../config/config.dart';

class RealizedWorksMapper{

  static jsonToEntity( Map<String, dynamic> json) => Works(
    id: json['id'].toString(), 
    name: json['titulo'] ?? json['name'] ?? '',
    description: json['descripcion'] ?? json['description'] ?? '',
    image: json['imagen_despues'] ?? json['imagen_antes'] ?? json['image'] ?? '',
    testimonial: json['testimonio'] ?? '',
    rating: _parseInt(json['calificacion']),
    isFeatured: json['destacado'] ?? false,
    isActive: json['activo'] ?? true,
    date: json['fecha'] ?? '',
    vehicleModelId: json['id_modelo_vehiculo'] != null
        ? _parseInt(json['id_modelo_vehiculo'])
        : null,
    beforeImage: json['imagen_antes'] ?? '',
    afterImage: json['imagen_despues'] ?? '',
    // .startsWith('http')
    //   ? json['image']
    //   : '${Enviroment.baseUrl}/realized-works-rest/${json['image']}',
    //  != null 
    //   ? List<String>.from(json['images'].map(
    //     (image) => image.startsWith('http')
    //       ? image 
    //       : '${Enviroment.baseUrl}/realized-works-rest/$image'
    //     ))
    //   : [], 
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
