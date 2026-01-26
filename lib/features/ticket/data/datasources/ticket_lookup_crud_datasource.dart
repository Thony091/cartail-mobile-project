import '../../../shared/domain/entities/state.dart' as lookup;

abstract class TicketLookupCrudDatasource {
  Future<List<lookup.State>> getAll();
  Future<lookup.State?> getById(int id);
  Future<lookup.State?> create(String name);
  Future<lookup.State?> update({required int id, required String name});
  Future<void> delete(int id);
}
