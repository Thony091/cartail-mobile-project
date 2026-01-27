import '../../domain/repositories/state_repository.dart';
import '../../../shared/domain/entities/state.dart';
import '../datasources/state_datasource.dart';

class StateRepositoryImpl extends StateRepository {
  final StateDatasource datasource;

  StateRepositoryImpl(this.datasource);

  @override
  Future<List<State>> getStates() {
    return datasource.getStates();
  }

  @override
  Future<State?> getStateById(int id) {
    return datasource.getStateById(id);
  }

  @override
  Future<State?> createState(String name) {
    return datasource.createState(name);
  }

  @override
  Future<State?> updateState({required int id, required String name}) {
    return datasource.updateState(id: id, name: name);
  }
}
