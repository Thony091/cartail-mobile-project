import '../domain.dart';

abstract class ProductsRepository {
  Future<List<Product>> getProductsByPage({ int limit = 10, int offset = 0 });
  Future<Product> getProductById( String id );
  Future<List<Product>> searchProductByTerm( String term );
  Future<List<Product>> getProductsByCategory( String categoryId );
  Future<Product> createUpdateProduct( Map<String, dynamic> productSimilar );
  Future<void> deleteProduct( String id );
}