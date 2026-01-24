import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/client.dart';
import '../errors/client_errors.dart';
import '../mappers/client_mapper.dart';
import 'client_datasource.dart';

class ClientDatasourceImpl extends ClientDatasource {
  late final Dio dio;
  final String accessToken;

  ClientDatasourceImpl({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Enviroment.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            // 'Authorization': 'Bearer $accessToken',
          },
        ),
      );

  @override
  Future<Client> createUpdateClient(Map<String, dynamic> clientSimilar) async {
    try {
      final String? clientId = clientSimilar['id']?.toString();
      final String method = (clientId == null) ? 'POST' : 'PATCH';
      final String url = (clientId == null) ? '/cliente' : '/cliente/$clientId';
      clientSimilar.remove('id');

      final response = await dio.request(
        url,
        data: clientSimilar,
        options: Options(method: method),
      );

      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return ClientMapper.jsonToEntity(data);
      }
      return _emptyClient();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      await dio.delete('/cliente/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Client> getClientById(String id) async {
    try {
      final response = await dio.get('/cliente/$id');
      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return ClientMapper.jsonToEntity(data);
      }
      return _emptyClient();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) throw ClientNotFound();
      throw e;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Client>> getClients() async {
    try {
      final response = await dio.get('/cliente');
      final List<Client> clients = [];
      final data = _extractData(response.data);
      if (data is List) {
        for (final client in data) {
          if (client is Map<String, dynamic>) {
            clients.add(ClientMapper.jsonToEntity(client));
          }
        }
      }
      return clients;
    } catch (e) {
      return [];
    }
  }

  Client _emptyClient() {
    return Client(id: 0, name: '', email: '', phone: '');
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
