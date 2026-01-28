import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../../../core/connectivity/connectivity_providers.dart';
import '../../../../core/providers/isar_service_provider.dart';
import '../../../sync_queue/presentation/providers/sync_queue_repository_provider.dart';
import '../../data/datasources/local/service_local_datasource_impl.dart';
import '../../data/datasources/service_datasource_impl.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/repositories/services_repository.dart';

/// Provider del repositorio de servicios (offline-first).
final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';
  final localDatasource = ServiceLocalDatasourceImpl(
    isarService: ref.watch(isarServiceProvider),
  );

  return ServicesRepositoryImpl(
    remoteDatasource: ServicesDatasourceImpl(accessToken: accessToken),
    localDatasource: localDatasource,
    connectivityService: ref.watch(connectivityServiceProvider),
    syncQueueRepository: ref.watch(syncQueueRepositoryProvider),
  );
});
