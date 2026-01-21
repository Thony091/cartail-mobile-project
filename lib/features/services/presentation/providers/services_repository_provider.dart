import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_datasource_impl.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/repositories/services_repository.dart';
import '../../../../presentation/presentation_container.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) { 

  final accessToken = ref.watch( authProvider ).token;
  
  final servicesRepository = ServicesRepositoryImpl(
    ServicesDatasourceImpl(accessToken: accessToken)
  );
  
  return servicesRepository;
});