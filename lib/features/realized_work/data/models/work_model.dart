import '../../domain/entities/works.dart';

class WorkModel {
  final String id;
  final String name;
  final String description;
  final String image;

  WorkModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory WorkModel.fromJson(Map<String, dynamic> json) {
    return WorkModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
    };
  }

  Works toEntity() {
    return Works(
      id: id,
      name: name,
      description: description,
      image: image,
    );
  }

  factory WorkModel.fromEntity(Works work) {
    return WorkModel(
      id: work.id,
      name: work.name,
      description: work.description,
      image: work.image,
    );
  }
}
