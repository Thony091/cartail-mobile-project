import '../../../shared/domain/entities/state.dart' as lookup;
import '../../domain/repositories/ticket_urgencia_repository.dart';
import '../datasources/local/ticket_urgencia_local_datasource.dart';
import '../datasources/ticket_lookup_crud_datasource.dart';

class TicketUrgenciaRepositoryImpl implements TicketUrgenciaRepository {
  TicketUrgenciaRepositoryImpl({
    required TicketLookupCrudDatasource remoteDatasource,
    required TicketUrgenciaLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  final TicketLookupCrudDatasource _remoteDatasource;
  final TicketUrgenciaLocalDatasource _localDatasource;

  @override
  Future<List<lookup.State>> getAll() async {
    final localItems = await _localDatasource.getAll();
    if (localItems.isNotEmpty) return localItems;

    final remoteItems = await _remoteDatasource.getAll();
    if (remoteItems.isNotEmpty) {
      await _localDatasource.cacheAll(remoteItems);
    }
    return remoteItems;
  }
}
