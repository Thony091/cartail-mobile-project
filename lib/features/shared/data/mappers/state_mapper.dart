import '../../domain/entities/state.dart';

class StateMapper {
  static State jsonToEntity(Map<String, dynamic> json) => State(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
  );

  static Map<String, dynamic> entityToJson(State state) => {
    'id': state.id,
    'name': state.name,
  };
}
