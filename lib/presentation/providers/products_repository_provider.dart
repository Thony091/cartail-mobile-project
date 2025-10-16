import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/presentation/presentation_container.dart';

import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).user?.user!.getIdToken().toString() ?? '' ;
  
  final productsRepository = ProductsRepositoryImpl(
    ProductsDatasourceImpl(accessToken: accessToken)
  );

  return productsRepository;
});