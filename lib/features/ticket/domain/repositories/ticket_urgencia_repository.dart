import '../../../shared/domain/entities/state.dart' as lookup;

abstract class TicketUrgenciaRepository {
  Future<List<lookup.State>> getAll();
}
