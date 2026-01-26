import '../../../shared/domain/entities/state.dart';

abstract class TicketLookupDatasource {
  Future<List<State>> getTicketStates();
  Future<List<State>> getTicketImportance();
  Future<List<State>> getTicketUrgency();
}
