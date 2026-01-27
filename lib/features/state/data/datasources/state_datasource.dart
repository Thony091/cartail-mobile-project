import '../../../shared/domain/entities/state.dart';

abstract class StateDatasource {
  Future<List<State>> getStates();
  Future<State?> getStateById(int id);
  Future<State?> createState(String name);
  Future<State?> updateState({required int id, required String name});
}
