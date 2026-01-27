import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/entities/state.dart';
import '../../domain/repositories/state_repository.dart';
import 'state_repository_provider.dart';

class StatesState {
  final bool isLoading;
  final List<State> states;
  final String? errorMessage;

  const StatesState({
    this.isLoading = false,
    this.states = const [],
    this.errorMessage,
  });

  StatesState copyWith({
    bool? isLoading,
    List<State>? states,
    String? errorMessage,
  }) {
    return StatesState(
      isLoading: isLoading ?? this.isLoading,
      states: states ?? this.states,
      errorMessage: errorMessage,
    );
  }
}

class StatesNotifier extends StateNotifier<StatesState> {
  final StateRepository repository;

  StatesNotifier(this.repository) : super(const StatesState());

  Future<void> load({bool force = false}) async {
    if (state.isLoading) return;
    if (!force && state.states.isNotEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final states = await repository.getStates();
      state = state.copyWith(isLoading: false, states: states);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<State?> createState(String name) async {
    try {
      final created = await repository.createState(name);
      if (created == null) {
        await load(force: true);
        return null;
      }
      final exists = state.states.any((item) => item.id == created.id);
      if (exists) {
        state = state.copyWith(
          states: state.states
              .map((item) => item.id == created.id ? created : item)
              .toList(),
        );
      } else {
        state = state.copyWith(states: [...state.states, created]);
      }
      return created;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<State?> updateState({required int id, required String name}) async {
    try {
      final updated = await repository.updateState(id: id, name: name);
      if (updated == null) {
        await load(force: true);
        return null;
      }
      state = state.copyWith(
        states: state.states
            .map((item) => item.id == updated.id ? updated : item)
            .toList(),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }
}

final statesNotifierProvider =
    StateNotifierProvider<StatesNotifier, StatesState>((ref) {
  final repo = ref.watch(stateRepositoryProvider);
  return StatesNotifier(repo)..load();
});

final statesProvider = Provider<List<State>>((ref) {
  return ref.watch(statesNotifierProvider).states;
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
