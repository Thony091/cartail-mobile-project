import '../../domain/entities/category.dart';

abstract class CategoryDatasource {
  Future<List<Category>> getCategories();
  Future<Category> getCategoryById(String id);
  Future<Category> createUpdateCategory(Map<String, dynamic> categorySimilar);
  Future<void> deleteCategory(String id);
}
