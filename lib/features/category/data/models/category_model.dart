import '../../domain/entities/category.dart';

class CategoryModel {
  final int id;
  final String name;
  final String description;
  final String slug;
  final int order;
  final bool isActive;
  final String icon;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.slug,
    required this.order,
    required this.isActive,
    required this.icon,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _parseInt(json['id'], defaultValue: 0),
      name: json['nombre'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ??
          json['descripcion'] as String? ??
          '',
      slug: json['slug'] as String? ?? '',
      order: _parseInt(json['orden'] ?? json['order'], defaultValue: 0),
      isActive: json['activo'] as bool? ??
          json['active'] as bool? ??
          true,
      icon: json['icono'] as String? ?? json['icon'] as String? ?? '',
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'nombre': name,
      'description': description,
      'slug': slug,
      'orden': order,
      'activo': isActive,
      'icono': icon,
    };

    if (createdAt != null) {
      json['created_at'] = createdAt!.toIso8601String();
    }

    return json;
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      slug: slug,
      order: order,
      isActive: isActive,
      icon: icon,
      createdAt: createdAt,
    );
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      slug: category.slug,
      order: category.order,
      isActive: category.isActive,
      icon: category.icon,
      createdAt: category.createdAt,
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
}
