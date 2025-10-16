
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';
import '../presentation_container.dart';

final worksRepositoryProvider = Provider<RealizedWorkRepository>((ref) {
  
  final accessToken = ref.watch( authProvider ).token;
  
  final worksRepository = RealizedWorksRepositoryImpl(
    RealizedWorkDatasourceImpl(accessToken: accessToken)
  );

  return worksRepository;
});