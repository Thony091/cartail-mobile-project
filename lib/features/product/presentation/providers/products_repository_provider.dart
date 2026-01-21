import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/presentation/presentation_container.dart';

import '../../data/datasources/products_datasource_impl.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/repositories/products_repository.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.user!.getIdToken().toString() ?? '' ;
  
  final productsRepository = ProductsRepositoryImpl(
    ProductsDatasourceImpl(accessToken: accessToken)
  );

  return productsRepository;
});