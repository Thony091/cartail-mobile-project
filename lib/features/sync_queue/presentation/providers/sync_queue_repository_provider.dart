import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/isar_service_provider.dart';
import '../../data/datasources/sync_queue_local_datasource.dart';
import '../../data/repositories/sync_queue_repository_impl.dart';
import '../../domain/repositories/sync_queue_repository.dart';

/// Provider del repositorio de SyncQueue (solo almacenamiento local).
final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  final local = SyncQueueLocalDatasource(
    isarService: ref.watch(isarServiceProvider),
  );
  return SyncQueueRepositoryImpl(localDatasource: local);
});
