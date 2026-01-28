import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../../shared/domain/entities/state.dart' as lookup;
import '../../data/datasources/ticket_lookup_crud_datasource_impl.dart';
import '../../data/repositories/ticket_lookup_crud_repository_impl.dart';
import '../../domain/repositories/ticket_lookup_crud_repository.dart';
import '../../data/repositories/ticket_estado_repository_impl.dart';
import '../../data/repositories/ticket_importancia_repository_impl.dart';
import '../../data/repositories/ticket_urgencia_repository_impl.dart';
import '../../domain/repositories/ticket_estado_repository.dart';
import '../../domain/repositories/ticket_importancia_repository.dart';
import '../../domain/repositories/ticket_urgencia_repository.dart';

class TicketLookupCrudState {
  final bool isLoading;
  final List<lookup.State> items;
  final String? errorMessage;

  const TicketLookupCrudState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  TicketLookupCrudState copyWith({
    bool? isLoading,
    List<lookup.State>? items,
    String? errorMessage,
  }) {
    return TicketLookupCrudState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}

class TicketLookupCrudNotifier extends StateNotifier<TicketLookupCrudState> {
  final TicketLookupCrudRepository repository;

  TicketLookupCrudNotifier(this.repository) : super(const TicketLookupCrudState());

  Future<void> load({bool force = false}) async {
    if (state.isLoading) return;
    if (!force && state.items.isNotEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getAll();
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<lookup.State?> createItem(String name) async {
    try {
      final created = await repository.create(name);
      if (created == null) {
        await load(force: true);
        return null;
      }
      final exists = state.items.any((item) => item.id == created.id);
      if (exists) {
        state = state.copyWith(
          items: state.items
              .map((item) => item.id == created.id ? created : item)
              .toList(),
        );
      } else {
        state = state.copyWith(items: [...state.items, created]);
      }
      return created;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<lookup.State?> updateItem({required int id, required String name}) async {
    try {
      final updated = await repository.update(id: id, name: name);
      if (updated == null) {
        await load(force: true);
        return null;
      }
      state = state.copyWith(
        items: state.items
            .map((item) => item.id == updated.id ? updated : item)
            .toList(),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      await repository.delete(id);
      state = state.copyWith(
        items: state.items.where((item) => item.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

TicketLookupCrudRepository _buildLookupRepository(
  Ref ref, {
  required String path,
}) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';
  return TicketLookupCrudRepositoryImpl(
    TicketLookupCrudDatasourceImpl(
      path: path,
      accessToken: accessToken,
    ),
  );
}

final ticketEstadosRepositoryProvider =
    Provider<TicketLookupCrudRepository>((ref) {
  return _buildLookupRepository(ref, path: '/estado-ticket');
});

final ticketEstadosCrudProvider =
    StateNotifierProvider<TicketLookupCrudNotifier, TicketLookupCrudState>((ref) {
  final repo = ref.watch(ticketEstadosRepositoryProvider);
  return TicketLookupCrudNotifier(repo)..load();
});

final ticketImportanciasRepositoryProvider =
    Provider<TicketLookupCrudRepository>((ref) {
  return _buildLookupRepository(ref, path: '/importancia-ticket');
});

final _ticketImportanciasCrudProvider =
    StateNotifierProvider<TicketLookupCrudNotifier, TicketLookupCrudState>((ref) {
  final repo = ref.watch(ticketImportanciasRepositoryProvider);
  return TicketLookupCrudNotifier(repo)..load();
});

// Repositories remotos por tipo (sin cache local)
final ticketEstadoRepositoryProvider =
    Provider<TicketEstadoRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';
  return TicketEstadoRepositoryImpl(
    remoteDatasource: TicketLookupCrudDatasourceImpl(
      path: '/estado-ticket',
      accessToken: accessToken,
    ),
  );
});

final ticketImportanciaRepositoryProvider =
    Provider<TicketImportanciaRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';
  return TicketImportanciaRepositoryImpl(
    remoteDatasource: TicketLookupCrudDatasourceImpl(
      path: '/importancia-ticket',
      accessToken: accessToken,
    ),
  );
});

final ticketUrgenciaRepositoryProvider =
    Provider<TicketUrgenciaRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';
  return TicketUrgenciaRepositoryImpl(
    remoteDatasource: TicketLookupCrudDatasourceImpl(
      path: '/urgencia-ticket',
      accessToken: accessToken,
    ),
  );
});

// Providers de lectura offline-first por tipo
final ticketEstadosProvider = FutureProvider<List<lookup.State>>((ref) async {
  final repo = ref.watch(ticketEstadoRepositoryProvider);
  return repo.getAll();
});

final ticketImportanciasProvider = FutureProvider<List<lookup.State>>((ref) async {
  final repo = ref.watch(ticketImportanciaRepositoryProvider);
  return repo.getAll();
});

final ticketUrgenciasProvider = FutureProvider<List<lookup.State>>((ref) async {
  final repo = ref.watch(ticketUrgenciaRepositoryProvider);
  return repo.getAll();
});

// CRUD provider for compatibility
final ticketImportanciasCrudProvider = Provider<TicketLookupCrudState>((ref) {
  return ref.watch(_ticketImportanciasCrudProvider);
});

final ticketUrgenciasRepositoryProvider =
    Provider<TicketLookupCrudRepository>((ref) {
  return _buildLookupRepository(ref, path: '/urgencia-ticket');
});

final _ticketUrgenciasCrudProvider =
    StateNotifierProvider<TicketLookupCrudNotifier, TicketLookupCrudState>((ref) {
  final repo = ref.watch(ticketUrgenciasRepositoryProvider);
  return TicketLookupCrudNotifier(repo)..load();
});

// CRUD provider for compatibility
final ticketUrgenciasCrudProvider = Provider<TicketLookupCrudState>((ref) {
  return ref.watch(_ticketUrgenciasCrudProvider);
});
