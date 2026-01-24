import '../../domain/entities/message.dart';

class MessageMapper{

  static jsonToEntity( Map<String, dynamic> json) => Message(
    id: json['id'].toString(), 
    name: json['nombre'] ?? json['name'] ?? '',
    email: json['email'] ?? '',
    message: json['mensaje'] ?? json['message'] ?? '',
  );
}
