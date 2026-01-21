import '../../domain/entities/message.dart';

class MessageModel {
  final String id;
  final String name;
  final String email;
  final String message;

  MessageModel({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'message': message,
    };
  }

  Message toEntity() {
    return Message(
      id: id,
      name: name,
      email: email,
      message: message,
    );
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      name: message.name,
      email: message.email,
      message: message.message,
    );
  }
}
