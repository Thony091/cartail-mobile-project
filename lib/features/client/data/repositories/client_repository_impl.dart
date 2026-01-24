import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_datasource.dart';

class ClientRepositoryImpl extends ClientRepository {
  final ClientDatasource clientDatasource;

  ClientRepositoryImpl(this.clientDatasource);

  @override
  Future<Client> createUpdateClient(Map<String, dynamic> clientSimilar) {
    return clientDatasource.createUpdateClient(clientSimilar);
  }

  @override
  Future<void> deleteClient(String id) {
    return clientDatasource.deleteClient(id);
  }

  @override
  Future<Client> getClientById(String id) {
    return clientDatasource.getClientById(id);
  }

  @override
  Future<List<Client>> getClients() {
    return clientDatasource.getClients();
  }

  @override
  Future<Client?> findClientByEmailOrPhone({
    required String email,
    required String phone,
  }) async {
    final clients = await clientDatasource.getClients();
    try {
      return clients.firstWhere(
        (client) =>
            (email.isNotEmpty &&
                client.email.toLowerCase() == email.toLowerCase()) ||
            (phone.isNotEmpty && client.phone == phone),
      );
    } catch (e) {
      return null;
    }
  }
}
