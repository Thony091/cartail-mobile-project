import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/connectivity/connectivity_providers.dart';
import '../../../../core/providers/isar_service_provider.dart';
import '../../../sync_queue/presentation/providers/sync_queue_repository_provider.dart';
import '../../data/datasources/local/user_local_datasource_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';

/// Provider del repositorio de usuarios (offline-first).
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final localDatasource = UserLocalDatasourceImpl(
    isarService: ref.watch(isarServiceProvider),
  );

  return UserRepositoryImpl(
    localDatasource: localDatasource,
    connectivityService: ref.watch(connectivityServiceProvider),
    syncQueueRepository: ref.watch(syncQueueRepositoryProvider),
  );
});
