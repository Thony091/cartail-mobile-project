import '../../domain/entities/category.dart';

class CategoryMapper {
  static Category jsonToEntity(Map<String, dynamic> json) => Category(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    isActive: json['active'] as bool? ?? true,
    createdAt: json['created_at'] != null
      ? DateTime.parse(json['created_at'] as String)
      : DateTime.now(),
  );

  static Map<String, dynamic> entityToJson(Category category) => {
    'id': category.id,
    'name': category.name,
    'description': category.description,
    'active': category.isActive,
    'created_at': category.createdAt.toIso8601String(),
  };
}
