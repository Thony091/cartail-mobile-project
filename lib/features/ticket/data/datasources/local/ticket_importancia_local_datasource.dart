import '../../../../shared/domain/entities/state.dart' as lookup;

abstract class TicketImportanciaLocalDatasource {
  Future<List<lookup.State>> getAll();
  Future<void> cacheAll(List<lookup.State> items);
}
