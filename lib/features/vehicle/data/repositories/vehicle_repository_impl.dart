import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/offline_first/offline_first_executor.dart';
import '../../../sync_queue/domain/entities/sync_queue_item.dart';
import '../../../sync_queue/domain/repositories/sync_queue_repository.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/local/vehicle_local_datasource.dart';
import '../datasources/vehicle_datasource.dart';
import '../models/vehicle_model.dart';
import '../../../shared/data/models/isar_domain_models.dart' as isar_models;

class VehicleRepositoryImpl extends VehicleRepository {
  VehicleRepositoryImpl({
    required VehicleDatasource remoteDatasource,
    required VehicleLocalDatasource localDatasource,
    required ConnectivityService connectivityService,
    required SyncQueueRepository syncQueueRepository,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _offlineFirstExecutor = OfflineFirstExecutor(
          connectivityService: connectivityService,
          syncQueueRepository: syncQueueRepository,
        );

  final VehicleDatasource _remoteDatasource;
  final VehicleLocalDatasource _localDatasource;
  final OfflineFirstExecutor _offlineFirstExecutor;

  @override
  Future<List<Vehicle>> getVehicles() {
    return _offlineFirstExecutor.read<List<Vehicle>>(
      local: () async {
        final models = await _localDatasource.getAll();
        return models.map(_isarToEntity).toList();
      },
      remote: _remoteDatasource.getVehicles,
      cache: (vehicles) async {
        await _cacheAll(vehicles);
      },
    );
  }

  @override
  Future<Vehicle> getVehicleById(String id) {
    return _offlineFirstExecutor.read<Vehicle>(
      local: () async {
        final model = await _localDatasource.getByBackendId(id);
        if (model == null) {
          throw StateError('Vehicle not found locally: $id');
        }
        return _isarToEntity(model);
      },
      remote: () => _remoteDatasource.getVehicleById(id),
      cache: (vehicle) async {
        await _localDatasource.upsert(_entityToIsar(vehicle, isSynced: true));
      },
    );
  }

  @override
  Future<Vehicle> createUpdateVehicle(Map<String, dynamic> vehicleSimilar) {
    final entity = VehicleModel.fromJson(vehicleSimilar).toEntity();
    final action = _actionFromMap(vehicleSimilar);

    return _offlineFirstExecutor.write<Vehicle>(
      localWrite: () async {
        final localEntity = _ensureBackendId(entity);
        await _localDatasource.upsert(
          _entityToIsar(localEntity, isSynced: false),
        );
        return localEntity;
      },
      remoteWrite: () => _remoteDatasource.createUpdateVehicle(vehicleSimilar),
      cache: (vehicle) async {
        await _localDatasource.upsert(_entityToIsar(vehicle, isSynced: true));
      },
      queueItem: () => SyncQueueItem.newItem(
        action: action,
        entity: SyncEntityType.vehicle,
        payload: VehicleModel.fromEntity(entity).toJson(),
      ),
    );
  }

  @override
  Future<void> deleteVehicle(String id) {
    return _offlineFirstExecutor.write<void>(
      localWrite: () async {
        await _localDatasource.deleteByBackendId(id);
      },
      remoteWrite: () => _remoteDatasource.deleteVehicle(id),
      cache: (_) async {},
      queueItem: () => SyncQueueItem.newItem(
        action: SyncActionType.delete,
        entity: SyncEntityType.vehicle,
        payload: {'id': id},
      ),
    );
  }

  Future<void> _cacheAll(List<Vehicle> vehicles) async {
    for (final vehicle in vehicles) {
      await _localDatasource.upsert(_entityToIsar(vehicle, isSynced: true));
    }
  }

  Vehicle _isarToEntity(isar_models.VehicleModel model) {
    return Vehicle(
      id: int.tryParse(model.backendId) ?? 0,
      brand: model.brand,
      model: model.model,
      year: model.year,
      trim: model.trim,
    );
  }

  isar_models.VehicleModel _entityToIsar(Vehicle vehicle, {required bool isSynced}) {
    return isar_models.VehicleModel()
      ..backendId = vehicle.id.toString()
      ..brand = vehicle.brand
      ..model = vehicle.model
      ..year = vehicle.year
      ..trim = vehicle.trim
      ..isSynced = isSynced
      ..updatedAt = DateTime.now();
  }

  Vehicle _ensureBackendId(Vehicle vehicle) {
    if (vehicle.id != 0) return vehicle;
    return Vehicle(
      id: DateTime.now().millisecondsSinceEpoch,
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.year,
      trim: vehicle.trim,
    );
  }

  SyncActionType _actionFromMap(Map<String, dynamic> payload) {
    final id = payload['id']?.toString() ?? payload['backendId']?.toString();
    return (id == null || id.isEmpty) ? SyncActionType.create : SyncActionType.update;
  }
}
