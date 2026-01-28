import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../../../core/connectivity/connectivity_providers.dart';
import '../../../../core/providers/isar_service_provider.dart';
import '../../../sync_queue/presentation/providers/sync_queue_repository_provider.dart';
import '../../data/datasources/local/slot_local_datasource_impl.dart';
import '../../data/datasources/slot_datasource_impl.dart';
import '../../data/repositories/slot_repository_impl.dart';
import '../../domain/repositories/slot_repository.dart';

/// Provider del repositorio de slots (offline-first).
final slotRepositoryProvider = Provider<SlotRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';
  final localDatasource = SlotLocalDatasourceImpl(
    isarService: ref.watch(isarServiceProvider),
  );

  return SlotRepositoryImpl(
    remoteDatasource: SlotDatasourceImpl(accessToken: accessToken),
    localDatasource: localDatasource,
    connectivityService: ref.watch(connectivityServiceProvider),
    syncQueueRepository: ref.watch(syncQueueRepositoryProvider),
  );
});
