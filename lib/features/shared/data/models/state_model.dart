import '../../domain/entities/state.dart';

class StateModel {
  final int id;
  final String name;

  StateModel({
    required this.id,
    required this.name,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  State toEntity() {
    return State(
      id: id,
      name: name,
    );
  }

  factory StateModel.fromEntity(State state) {
    return StateModel(
      id: state.id,
      name: state.name,
    );
  }
}
