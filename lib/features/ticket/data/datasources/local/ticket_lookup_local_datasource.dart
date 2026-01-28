import '../../../../shared/domain/entities/state.dart' as lookup;

abstract class TicketLookupLocalDatasource {
  Future<List<lookup.State>> getEstados();
  Future<List<lookup.State>> getImportancias();
  Future<List<lookup.State>> getUrgencias();

  Future<void> cacheEstados(List<lookup.State> items);
  Future<void> cacheImportancias(List<lookup.State> items);
  Future<void> cacheUrgencias(List<lookup.State> items);
}
