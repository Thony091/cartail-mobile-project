import '../../../../shared/domain/entities/state.dart' as lookup;

abstract class TicketUrgenciaLocalDatasource {
  Future<List<lookup.State>> getAll();
  Future<void> cacheAll(List<lookup.State> items);
}
