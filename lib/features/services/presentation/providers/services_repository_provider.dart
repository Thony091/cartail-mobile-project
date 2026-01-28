import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../data/datasources/service_datasource_impl.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/repositories/services_repository.dart';

/// Provider del repositorio de servicios (remote-only).
final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';

  return ServicesRepositoryImpl(
    remoteDatasource: ServicesDatasourceImpl(accessToken: accessToken),
  );
});
