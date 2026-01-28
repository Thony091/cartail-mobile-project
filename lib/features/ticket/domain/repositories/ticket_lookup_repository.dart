import '../../../shared/domain/entities/state.dart';

abstract class TicketLookupRepository {
  Future<List<State>> getEstados();
  Future<List<State>> getImportancias();
  Future<List<State>> getUrgencias();
}
