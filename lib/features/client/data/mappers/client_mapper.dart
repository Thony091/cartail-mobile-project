import '../../domain/entities/client.dart';
import '../models/client_model.dart';

class ClientMapper {
  static Client jsonToEntity(Map<String, dynamic> json) {
    return ClientModel.fromJson(json).toEntity();
  }

  static Map<String, dynamic> entityToJson(Client client) {
    return ClientModel.fromEntity(client).toJson();
  }
}
