import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_datasource.dart';

class CategoryRepositoryImpl extends CategoryRepository {
  final CategoryDatasource categoryDatasource;

  CategoryRepositoryImpl(this.categoryDatasource);

  @override
  Future<Category> createUpdateCategory(Map<String, dynamic> categorySimilar) {
    return categoryDatasource.createUpdateCategory(categorySimilar);
  }

  @override
  Future<void> deleteCategory(String id) {
    return categoryDatasource.deleteCategory(id);
  }

  @override
  Future<Category> getCategoryById(String id) {
    return categoryDatasource.getCategoryById(id);
  }

  @override
  Future<List<Category>> getCategories() {
    return categoryDatasource.getCategories();
  }
}
