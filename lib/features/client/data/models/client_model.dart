import '../../domain/entities/client.dart';

class ClientModel {
  final int id;
  final String name;
  final String email;
  final String phone;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: _parseInt(json['id'], defaultValue: 0),
      name: json['nombre'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['telefono'] as String? ?? json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'email': email,
      'telefono': phone,
    };
  }

  Client toEntity() {
    return Client(
      id: id,
      name: name,
      email: email,
      phone: phone,
    );
  }

  factory ClientModel.fromEntity(Client client) {
    return ClientModel(
      id: client.id,
      name: client.name,
      email: client.email,
      phone: client.phone,
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }
}
