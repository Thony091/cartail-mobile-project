
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../data/datasources/realized_work_datasource_impl.dart';
import '../../data/repositories/realized_works_repository_impl.dart';
import '../../domain/repositories/realized_work_repository.dart';

final worksRepositoryProvider = Provider<RealizedWorkRepository>((ref) {
  
  final accessToken = ref.watch( betterAuthProvider ).token ?? '';
  
  final worksRepository = RealizedWorksRepositoryImpl(
    RealizedWorkDatasourceImpl(accessToken: accessToken)
  );

  return worksRepository;
});