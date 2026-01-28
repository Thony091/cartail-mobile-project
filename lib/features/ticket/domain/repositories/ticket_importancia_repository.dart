import '../../../shared/domain/entities/state.dart' as lookup;

abstract class TicketImportanciaRepository {
  Future<List<lookup.State>> getAll();
}
