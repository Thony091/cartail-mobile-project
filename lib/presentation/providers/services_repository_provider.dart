

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/domain/domain.dart';

import '../../infrastructure/infrastructure.dart';
import '../presentation_container.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) { 

  final accessToken = ref.watch( authProvider ).token;
  
  final servicesRepository = ServicesRepositoryImpl(
    ServicesDatasourceImpl(accessToken: accessToken)
  );
  
  return servicesRepository;
});