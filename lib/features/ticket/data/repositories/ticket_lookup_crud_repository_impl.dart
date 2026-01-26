import '../../../shared/domain/entities/state.dart' as lookup;
import '../../domain/repositories/ticket_lookup_crud_repository.dart';
import '../datasources/ticket_lookup_crud_datasource.dart';

class TicketLookupCrudRepositoryImpl extends TicketLookupCrudRepository {
  final TicketLookupCrudDatasource datasource;

  TicketLookupCrudRepositoryImpl(this.datasource);

  @override
  Future<List<lookup.State>> getAll() => datasource.getAll();

  @override
  Future<lookup.State?> getById(int id) => datasource.getById(id);

  @override
  Future<lookup.State?> create(String name) => datasource.create(name);

  @override
  Future<lookup.State?> update({required int id, required String name}) {
    return datasource.update(id: id, name: name);
  }

  @override
  Future<void> delete(int id) => datasource.delete(id);
}
