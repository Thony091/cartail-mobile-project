import 'package:portafolio_project/config/constants/enviroment.dart';

import '../../domain/domain.dart';

class ProductMapper {

  static jsonToEntity( Map<String, dynamic> json) => Product(
    id: json['id'].toString(),
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: double.parse( json['price'].toString()),
    stock: json['stock'],
    images: json['images'] != null 
      ? List<String>.from(json['images'].map(
        (image) => image.startsWith('http')
          ? image 
          : '${Enviroment.baseUrl}/prduct-rest/$image'
        ))
      : [],
    isActive: json['active'], 
    categoryId: json['categoryId'],
  );

}