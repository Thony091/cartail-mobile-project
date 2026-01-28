import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../../../core/connectivity/connectivity_providers.dart';
import '../../../../core/providers/isar_service_provider.dart';
import '../../../sync_queue/presentation/providers/sync_queue_repository_provider.dart';
import '../../data/datasources/local/vehicle_local_datasource_impl.dart';
import '../../data/datasources/vehicle_datasource_impl.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/repositories/vehicle_repository.dart';

/// Provider del repositorio de vehículos (offline-first).
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';
  final localDatasource = VehicleLocalDatasourceImpl(
    isarService: ref.watch(isarServiceProvider),
  );

  return VehicleRepositoryImpl(
    remoteDatasource: VehicleDatasourceImpl(accessToken: accessToken),
    localDatasource: localDatasource,
    connectivityService: ref.watch(connectivityServiceProvider),
    syncQueueRepository: ref.watch(syncQueueRepositoryProvider),
  );
});
