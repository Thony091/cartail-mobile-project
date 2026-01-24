import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../../../presentation/presentation_container.dart';

final clientsProvider = StateNotifierProvider<ClientsNotifier, ClientsState>((ref) {
  final clientRepository = ref.watch(clientRepositoryProvider);
  return ClientsNotifier(clientRepository: clientRepository);
});

class ClientsNotifier extends StateNotifier<ClientsState> {
  final ClientRepository clientRepository;

  ClientsNotifier({required this.clientRepository}) : super(ClientsState()) {
    getClients();
  }

  Future<void> getClients() async {
    state = state.copyWith(loading: true, error: '');

    try {
      final clients = await clientRepository.getClients();
      state = state.copyWith(clients: clients, loading: false);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Error al obtener los clientes',
      );
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await clientRepository.deleteClient(id);
      state = state.copyWith(
        clients: state.clients.where((element) => element.id.toString() != id).toList(),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<Client?> createOrUpdateClient(Map<String, dynamic> clientSimilar) async {
    try {
      final client = await clientRepository.createUpdateClient(clientSimilar);
      final isInList = state.clients.any((element) => element.id == client.id);

      if (!isInList) {
        state = state.copyWith(clients: [...state.clients, client]);
        return client;
      }

      state = state.copyWith(
        clients: state.clients
            .map((element) => (element.id == client.id) ? client : element)
            .toList(),
      );
      return client;
    } catch (e) {
      return null;
    }
  }
}

class ClientsState {
  final List<Client> clients;
  final bool loading;
  final String error;

  ClientsState({
    this.clients = const [],
    this.loading = true,
    this.error = '',
  });

  ClientsState copyWith({
    List<Client>? clients,
    bool? loading,
    String? error,
  }) => ClientsState(
      clients: clients ?? this.clients,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
}
