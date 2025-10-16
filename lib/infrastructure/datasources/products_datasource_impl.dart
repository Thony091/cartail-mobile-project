import 'package:dio/dio.dart';

import '../../config/config.dart';
import '../../domain/domain.dart';
import '../infrastructure.dart';

class ProductsDatasourceImpl extends ProductsDatasource {

  late final Dio dio;
  final String accessToken;

  ProductsDatasourceImpl({
    required this.accessToken
  }) : dio = Dio(
    BaseOptions(
      baseUrl: '${Enviroment.baseUrl}/product-rest',
      headers: {
        'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
        'Authorization': 'Bearer $accessToken'
      }
    )
  );


  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productSimilar) {
    // TODO: implement createUpdateProduct
    throw UnimplementedError();
  }

  @override
  Future<Product> getProductById(String id) async {

    try {
      
      final response = await dio.get('/obtener-producto/$id');

      final product = ProductMapper.jsonToEntity(response.data);
      return product;

    } on DioException catch (e) {
      
      if ( e.response!.statusCode == 404 ) throw ProductNotFound();
      throw Exception();
      
    } catch (e) {
      throw Exception();
    }

  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) {
    // TODO: implement getProductsByCategory
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> getProductsByPage({int limit = 10, int offset = 0}) async {
    try {
      
      final response = await dio.get<List>('/listar-productos');
      final List<Product> products = [];

      if ( response.statusCode == 200 ){
        
        for ( final product in response.data ?? [] ) {
          products.add( ProductMapper.jsonToEntity(product) );
        }
        
      }
      return products;
      
    } catch (e) {

      print('Error: $e');
      return [];

    }
  }

  @override
  Future<List<Product>> searchProductByTerm(String term) {
    // TODO: implement searchProductByTerm
    throw UnimplementedError();
  }
  
  @override
  Future<void> deleteProduct(String id) {
    // TODO: implement deleteProduct
    throw UnimplementedError();
  }

}