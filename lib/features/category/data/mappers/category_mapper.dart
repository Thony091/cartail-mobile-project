import '../../domain/entities/category.dart';
import '../models/category_model.dart';

class CategoryMapper {
  static Category jsonToEntity(Map<String, dynamic> json) {
    return CategoryModel.fromJson(json).toEntity();
  }

  static Map<String, dynamic> entityToJson(Category category) {
    return CategoryModel.fromEntity(category).toJson();
  }
}
