import '../../domain/entities/client.dart';

abstract class ClientDatasource {
  Future<List<Client>> getClients();
  Future<Client> getClientById(String id);
  Future<Client> createUpdateClient(Map<String, dynamic> clientSimilar);
  Future<void> deleteClient(String id);
}
