import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/entities/state.dart';

final statesProvider = Provider<List<State>>((ref) {
  return [
    State(id: 1, name: 'Pendiente'),
    State(id: 2, name: 'Evaluando'),
    State(id: 3, name: 'En Progreso'),
    State(id: 4, name: 'Finalizado'),
    State(id: 5, name: 'Aprobado'),
  ];
});

final stateByIdProvider = Provider.family<State?, int>((ref, id) {
  final states = ref.watch(statesProvider);
  try {
    return states.firstWhere((state) => state.id == id);
  } catch (e) {
    return null;
  }
});

final stateByNameProvider = Provider.family<State?, String>((ref, name) {
  final states = ref.watch(statesProvider);
  try {
    return states.firstWhere(
      (state) => state.name.toLowerCase() == name.toLowerCase(),
    );
  } catch (e) {
    return null;
  }
});
