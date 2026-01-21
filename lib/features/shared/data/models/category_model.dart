import '../../domain/entities/category.dart';

class CategoryModel {
  final int id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['active'] as bool? ?? true,
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      isActive: category.isActive,
      createdAt: category.createdAt,
    );
  }
}
