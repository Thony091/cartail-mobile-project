import '../../../shared/domain/entities/state.dart';
import '../../domain/repositories/ticket_lookup_repository.dart';
import '../datasources/ticket_lookup_crud_datasource_impl.dart';

class TicketLookupRepositoryImpl extends TicketLookupRepository {
  TicketLookupRepositoryImpl({
    required TicketLookupCrudDatasourceImpl estadosDatasource,
    required TicketLookupCrudDatasourceImpl importanciasDatasource,
    required TicketLookupCrudDatasourceImpl urgenciasDatasource,
  })  : _estadosDatasource = estadosDatasource,
        _importanciasDatasource = importanciasDatasource,
        _urgenciasDatasource = urgenciasDatasource;

  final TicketLookupCrudDatasourceImpl _estadosDatasource;
  final TicketLookupCrudDatasourceImpl _importanciasDatasource;
  final TicketLookupCrudDatasourceImpl _urgenciasDatasource;

  @override
  Future<List<State>> getEstados() {
    return _estadosDatasource.getAll();
  }

  @override
  Future<List<State>> getImportancias() {
    return _importanciasDatasource.getAll();
  }

  @override
  Future<List<State>> getUrgencias() {
    return _urgenciasDatasource.getAll();
  }
}
