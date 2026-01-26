import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/entities/state.dart';
import '../../data/datasources/ticket_lookup_datasource_impl.dart';
import '../../data/repositories/ticket_lookup_repository_impl.dart';
import '../../domain/repositories/ticket_lookup_repository.dart';

class TicketLookupsState {
  final bool isLoading;
  final List<State> estados;
  final List<State> importancias;
  final List<State> urgencias;
  final String? errorMessage;

  const TicketLookupsState({
    this.isLoading = false,
    this.estados = const [],
    this.importancias = const [],
    this.urgencias = const [],
    this.errorMessage,
  });

  TicketLookupsState copyWith({
    bool? isLoading,
    List<State>? estados,
    List<State>? importancias,
    List<State>? urgencias,
    String? errorMessage,
  }) {
    return TicketLookupsState(
      isLoading: isLoading ?? this.isLoading,
      estados: estados ?? this.estados,
      importancias: importancias ?? this.importancias,
      urgencias: urgencias ?? this.urgencias,
      errorMessage: errorMessage,
    );
  }
}

class TicketLookupsNotifier extends StateNotifier<TicketLookupsState> {
  final TicketLookupRepository repository;

  TicketLookupsNotifier(this.repository) : super(const TicketLookupsState());

  Future<void> loadLookups({bool force = false}) async {
    if (state.isLoading) return;
    if (!force && state.estados.isNotEmpty && state.importancias.isNotEmpty && state.urgencias.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await Future.wait([
        repository.getTicketStates(),
        repository.getTicketImportance(),
        repository.getTicketUrgency(),
      ]);

      state = state.copyWith(
        isLoading: false,
        estados: results[0],
        importancias: results[1],
        urgencias: results[2],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final ticketLookupRepositoryProvider = Provider<TicketLookupRepository>((ref) {
  return TicketLookupRepositoryImpl(TicketLookupDatasourceImpl());
});

final ticketLookupsProvider =
    StateNotifierProvider<TicketLookupsNotifier, TicketLookupsState>((ref) {
  final repo = ref.watch(ticketLookupRepositoryProvider);
  return TicketLookupsNotifier(repo)..loadLookups();
});
