import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../../../core/connectivity/connectivity_providers.dart';
import '../../../../core/providers/isar_service_provider.dart';
import '../../../sync_queue/presentation/providers/sync_queue_repository_provider.dart';
import '../../data/datasources/local/reservation_local_datasource_impl.dart';
import '../../data/datasources/reservation_datasource_impl.dart';
import '../../data/repositories/reservation_repository_impl.dart';
import '../../domain/repositories/reservation_repository.dart';

/// Provider del repositorio de reservas (offline-first).
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';
  final localDatasource = ReservationLocalDatasourceImpl(
    isarService: ref.watch(isarServiceProvider),
  );

  return ReservationRepositoryImpl(
    remoteDatasource: ReservationDatasourceImpl(accessToken: accessToken),
    localDatasource: localDatasource,
    connectivityService: ref.watch(connectivityServiceProvider),
    syncQueueRepository: ref.watch(syncQueueRepositoryProvider),
  );
});
