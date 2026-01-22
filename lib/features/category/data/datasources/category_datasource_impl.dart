import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/category.dart';
import '../errors/category_errors.dart';
import '../mappers/category_mapper.dart';
import 'category_datasource.dart';

class CategoryDatasourceImpl extends CategoryDatasource {
  late final Dio dio;
  final String accessToken;

  CategoryDatasourceImpl({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Enviroment.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            // 'Authorization': 'Bearer $accessToken',
          },
        ),
      );

  @override
  Future<Category> createUpdateCategory(
    Map<String, dynamic> categorySimilar,
  ) async {
    try {
      final String? categoryId = categorySimilar['id']?.toString();
      final String method = (categoryId == null) ? 'POST' : 'PATCH';
      final String url = (categoryId == null)
          ? '/categoria'
          : '/categoria/$categoryId';
      categorySimilar.remove('id');

      final response = await dio.request(
        url,
        data: categorySimilar,
        options: Options(method: method),
      );

      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return CategoryMapper.jsonToEntity(data);
      }

      return _emptyCategory();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await dio.delete('/categoria/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Category> getCategoryById(String id) async {
    try {
      final response = await dio.get('/categoria/$id');

      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return CategoryMapper.jsonToEntity(data);
      }
      return _emptyCategory();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) throw CategoryNotFound();
      throw e;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await dio.get('/categoria');
      final List<Category> categories = [];

      final data = _extractData(response.data);
      if (data is List) {
        for (final category in data) {
          if (category is Map<String, dynamic>) {
            categories.add(CategoryMapper.jsonToEntity(category));
          }
        }
      }

      return categories;
    } catch (e) {
      return [];
    }
  }

  Category _emptyCategory() {
    return Category(
      id: 0,
      name: '',
      description: '',
      slug: '',
      order: 0,
      isActive: false,
      icon: '',
      createdAt: null,
    );
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
