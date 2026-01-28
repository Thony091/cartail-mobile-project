
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/offline_first/offline_first_executor.dart';
import '../../../sync_queue/domain/entities/sync_queue_item.dart';
import '../../../sync_queue/domain/repositories/sync_queue_repository.dart';
import '../../domain/entities/services.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/local/service_local_datasource.dart';
import '../datasources/services_datasources.dart';
import '../models/service_model.dart';
import '../../../shared/data/models/isar_domain_models.dart' as isar_models;

class ServicesRepositoryImpl extends ServicesRepository {
  ServicesRepositoryImpl({
    required ServicesDatasource remoteDatasource,
    required ServiceLocalDatasource localDatasource,
    required ConnectivityService connectivityService,
    required SyncQueueRepository syncQueueRepository,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _offlineFirstExecutor = OfflineFirstExecutor(
          connectivityService: connectivityService,
          syncQueueRepository: syncQueueRepository,
        );

  final ServicesDatasource _remoteDatasource;
  final ServiceLocalDatasource _localDatasource;
  final OfflineFirstExecutor _offlineFirstExecutor;

  @override
  Future<List<Services>> getServices() {
    return _offlineFirstExecutor.read<List<Services>>(
      local: () async {
        final models = await _localDatasource.getAll();
        return models.map(_isarToEntity).toList();
      },
      remote: _remoteDatasource.getServices,
      cache: (services) async {
        await _cacheAll(services);
      },
    );
  }

  @override
  Future<Services> getServiceById(String id) {
    return _offlineFirstExecutor.read<Services>(
      local: () async {
        final model = await _localDatasource.getByBackendId(id);
        if (model == null) {
          throw StateError('Service not found locally: $id');
        }
        return _isarToEntity(model);
      },
      remote: () => _remoteDatasource.getServiceById(id),
      cache: (service) async {
        await _localDatasource.upsert(_entityToIsar(service, isSynced: true));
      },
    );
  }

  @override
  Future<Services> createUpdateService(Map<String, dynamic> serviceSimilar) {
    final entity = ServiceModel.fromJson(serviceSimilar).toEntity();
    final action = _actionFromMap(serviceSimilar);

    return _offlineFirstExecutor.write<Services>(
      localWrite: () async {
        final localEntity = _ensureBackendId(entity);
        await _localDatasource.upsert(
          _entityToIsar(localEntity, isSynced: false),
        );
        return localEntity;
      },
      remoteWrite: () => _remoteDatasource.createUpdateService(serviceSimilar),
      cache: (service) async {
        await _localDatasource.upsert(_entityToIsar(service, isSynced: true));
      },
      queueItem: () => SyncQueueItem.newItem(
        action: action,
        entity: SyncEntityType.service,
        payload: ServiceModel.fromEntity(entity).toJson(),
      ),
    );
  }

  @override
  Future<void> deleteService(String id) {
    return _offlineFirstExecutor.write<void>(
      localWrite: () async {
        await _localDatasource.deleteByBackendId(id);
      },
      remoteWrite: () => _remoteDatasource.deleteService(id),
      cache: (_) async {},
      queueItem: () => SyncQueueItem.newItem(
        action: SyncActionType.delete,
        entity: SyncEntityType.service,
        payload: {'id': id},
      ),
    );
  }

  Future<void> _cacheAll(List<Services> services) async {
    for (final service in services) {
      await _localDatasource.upsert(_entityToIsar(service, isSynced: true));
    }
  }

  Services _isarToEntity(isar_models.ServiceModel model) {
    return Services(
      id: model.backendId,
      name: model.name,
      description: model.description,
      minPrice: model.minPrice,
      maxPrice: model.maxPrice,
      durationMinutes: model.durationMinutes,
      requiresReservation: model.requiresReservation,
      images: model.images,
      isActive: model.isActive,
      categoryId: model.categoryId,
    );
  }

  isar_models.ServiceModel _entityToIsar(Services service, {required bool isSynced}) {
    return isar_models.ServiceModel()
      ..backendId = service.id
      ..name = service.name
      ..description = service.description
      ..minPrice = service.minPrice
      ..maxPrice = service.maxPrice
      ..durationMinutes = service.durationMinutes
      ..requiresReservation = service.requiresReservation
      ..isActive = service.isActive
      ..images = service.images
      ..categoryId = service.categoryId
      ..isSynced = isSynced
      ..updatedAt = DateTime.now();
  }

  Services _ensureBackendId(Services service) {
    if (service.id.isNotEmpty) return service;
    return Services(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      name: service.name,
      description: service.description,
      minPrice: service.minPrice,
      maxPrice: service.maxPrice,
      durationMinutes: service.durationMinutes,
      requiresReservation: service.requiresReservation,
      images: service.images,
      isActive: service.isActive,
      categoryId: service.categoryId,
    );
  }

  SyncActionType _actionFromMap(Map<String, dynamic> payload) {
    final id = payload['id']?.toString() ?? payload['backendId']?.toString();
    return (id == null || id.isEmpty) ? SyncActionType.create : SyncActionType.update;
  }
}
 
