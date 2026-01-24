import '../entities/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients();
  Future<Client> getClientById(String id);
  Future<Client> createUpdateClient(Map<String, dynamic> clientSimilar);
  Future<void> deleteClient(String id);
  Future<Client?> findClientByEmailOrPhone({
    required String email,
    required String phone,
  });
}
