import '../../../shared/domain/entities/state.dart' as lookup;
import '../../domain/repositories/ticket_estado_repository.dart';
import '../datasources/ticket_lookup_crud_datasource.dart';

class TicketEstadoRepositoryImpl implements TicketEstadoRepository {
  TicketEstadoRepositoryImpl({
    required TicketLookupCrudDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final TicketLookupCrudDatasource _remoteDatasource;

  @override
  Future<List<lookup.State>> getAll() async {
    return _remoteDatasource.getAll();
  }
}
