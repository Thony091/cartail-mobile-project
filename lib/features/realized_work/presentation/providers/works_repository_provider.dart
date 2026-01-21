
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/realized_work_datasource_impl.dart';
import '../../data/repositories/realized_works_repository_impl.dart';
import '../../domain/repositories/realized_work_repository.dart';
import '../../../../presentation/presentation_container.dart';

final worksRepositoryProvider = Provider<RealizedWorkRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).token;
  
  final worksRepository = RealizedWorksRepositoryImpl(
    RealizedWorkDatasourceImpl(accessToken: accessToken)
  );

  return worksRepository;
});