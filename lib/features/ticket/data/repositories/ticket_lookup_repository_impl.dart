import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/offline_first/offline_first_executor.dart';
import '../../../shared/domain/entities/state.dart';
import '../../../sync_queue/domain/repositories/sync_queue_repository.dart';
import '../../domain/repositories/ticket_lookup_repository.dart';
import '../datasources/local/ticket_lookup_local_datasource.dart';
import '../datasources/ticket_lookup_crud_datasource_impl.dart';

class TicketLookupRepositoryImpl extends TicketLookupRepository {
  TicketLookupRepositoryImpl({
    required TicketLookupCrudDatasourceImpl estadosDatasource,
    required TicketLookupCrudDatasourceImpl importanciasDatasource,
    required TicketLookupCrudDatasourceImpl urgenciasDatasource,
    required TicketLookupLocalDatasource localDatasource,
    required ConnectivityService connectivityService,
    required SyncQueueRepository syncQueueRepository,
  })  : _estadosDatasource = estadosDatasource,
        _importanciasDatasource = importanciasDatasource,
        _urgenciasDatasource = urgenciasDatasource,
        _localDatasource = localDatasource,
        _offlineFirstExecutor = OfflineFirstExecutor(
          connectivityService: connectivityService,
          syncQueueRepository: syncQueueRepository,
        );

  final TicketLookupCrudDatasourceImpl _estadosDatasource;
  final TicketLookupCrudDatasourceImpl _importanciasDatasource;
  final TicketLookupCrudDatasourceImpl _urgenciasDatasource;
  final TicketLookupLocalDatasource _localDatasource;
  final OfflineFirstExecutor _offlineFirstExecutor;

  @override
  Future<List<State>> getEstados() {
    return _offlineFirstExecutor.readStaleWhileRevalidate<List<State>>(
      local: _localDatasource.getEstados,
      remote: _estadosDatasource.getAll,
      cache: _localDatasource.cacheEstados,
      isEmpty: (states) => states.isEmpty,
    );
  }

  @override
  Future<List<State>> getImportancias() {
    return _offlineFirstExecutor.readStaleWhileRevalidate<List<State>>(
      local: _localDatasource.getImportancias,
      remote: _importanciasDatasource.getAll,
      cache: _localDatasource.cacheImportancias,
      isEmpty: (states) => states.isEmpty,
    );
  }

  @override
  Future<List<State>> getUrgencias() {
    return _offlineFirstExecutor.readStaleWhileRevalidate<List<State>>(
      local: _localDatasource.getUrgencias,
      remote: _urgenciasDatasource.getAll,
      cache: _localDatasource.cacheUrgencias,
      isEmpty: (states) => states.isEmpty,
    );
  }
}
