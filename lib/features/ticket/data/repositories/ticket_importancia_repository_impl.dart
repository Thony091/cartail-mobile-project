import '../../../shared/domain/entities/state.dart' as lookup;
import '../../domain/repositories/ticket_importancia_repository.dart';
import '../datasources/ticket_lookup_crud_datasource.dart';

class TicketImportanciaRepositoryImpl implements TicketImportanciaRepository {
  TicketImportanciaRepositoryImpl({
    required TicketLookupCrudDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final TicketLookupCrudDatasource _remoteDatasource;

  @override
  Future<List<lookup.State>> getAll() async {
    return _remoteDatasource.getAll();
  }
}
