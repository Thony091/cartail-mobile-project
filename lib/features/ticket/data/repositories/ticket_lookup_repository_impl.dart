import '../../../shared/domain/entities/state.dart';
import '../../domain/repositories/ticket_lookup_repository.dart';
import '../datasources/ticket_lookup_datasource.dart';

class TicketLookupRepositoryImpl extends TicketLookupRepository {
  final TicketLookupDatasource datasource;

  TicketLookupRepositoryImpl(this.datasource);

  @override
  Future<List<State>> getTicketStates() => datasource.getTicketStates();

  @override
  Future<List<State>> getTicketImportance() => datasource.getTicketImportance();

  @override
  Future<List<State>> getTicketUrgency() => datasource.getTicketUrgency();
}
