import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../../../core/connectivity/connectivity_providers.dart';
import '../../../../core/providers/isar_service_provider.dart';
import '../../../sync_queue/presentation/providers/sync_queue_repository_provider.dart';
import '../../data/datasources/local/ticket_local_datasource_impl.dart';
import '../../data/datasources/ticket_datasource_impl.dart';
import '../../data/repositories/ticket_repository_impl.dart';
import '../../domain/repositories/ticket_repository.dart';

/// Provider del repositorio de tickets (offline-first).
final ticketsRepositoryProvider = Provider<TicketRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';
  final localDatasource = TicketLocalDatasourceImpl(
    isarService: ref.watch(isarServiceProvider),
  );

  return TicketRepositoryImpl(
    remoteDatasource: TicketDatasourceImpl(accessToken: accessToken),
    localDatasource: localDatasource,
    connectivityService: ref.watch(connectivityServiceProvider),
    syncQueueRepository: ref.watch(syncQueueRepositoryProvider),
  );
});
