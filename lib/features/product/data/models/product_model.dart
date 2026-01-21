import 'package:portafolio_project/config/constants/enviroment.dart';
import '../../domain/entities/product.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isActive;
  final List<String> images;
  final int stock;
  final int categoryId;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.isActive,
    required this.stock,
    required this.categoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.parse(json['price'].toString()),
      stock: json['stock'] as int? ?? 0,
      images: json['images'] != null
        ? List<String>.from(json['images'].map(
            (image) => image.startsWith('http')
              ? image
              : '${Enviroment.baseUrl}/prduct-rest/$image'
          ))
        : [],
      isActive: json['active'] as bool? ?? false,
      categoryId: json['categoryId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'images': images,
      'active': isActive,
      'categoryId': categoryId,
    };
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      images: images,
      isActive: isActive,
      stock: stock,
      categoryId: categoryId,
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      images: product.images,
      isActive: product.isActive,
      stock: product.stock,
      categoryId: product.categoryId,
    );
  }
}
