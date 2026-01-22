import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/presentation_container.dart';

import '../../data/datasources/category_datasource_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final accessToken = ref.watch(authProvider).user?.user!.getIdToken().toString() ?? '';

  final categoryRepository = CategoryRepositoryImpl(
    CategoryDatasourceImpl(accessToken: accessToken),
  );

  return categoryRepository;
});
