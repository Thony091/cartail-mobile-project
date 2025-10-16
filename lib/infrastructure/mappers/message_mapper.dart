import '../../domain/domain.dart';

class MessageMapper{

  static jsonToEntity( Map<String, dynamic> json) => Message(
    id: json['id'].toString(), 
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    message: json['message'] ?? '',
  );
}