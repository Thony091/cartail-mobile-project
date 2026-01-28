import '../../../shared/domain/entities/state.dart' as lookup;

abstract class TicketEstadoRepository {
  Future<List<lookup.State>> getAll();
}
