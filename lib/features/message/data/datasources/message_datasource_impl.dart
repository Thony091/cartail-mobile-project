// ignore_for_file: use_rethrow_when_possible
import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../../services/data/errors/service_errors.dart';
import '../../domain/entities/message.dart';
import '../mappers/message_mapper.dart';
import 'message_datasources.dart';

class MessageDatasourceImpl extends MessageDatasource {
  late final Dio dio;
  final String accessToken;

  MessageDatasourceImpl({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Enviroment.baseUrl,
          headers: {
            // 'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
            // 'Authorization': 'Bearer $accessToken'
          },
        ),
      );

  @override
  Future<Message> createUpdateMessage(
    String name,
    String email,
    String message,
  ) async {
    try {
      final data = {'nombre': name, 'email': email, 'mensaje': message};

      final response = await dio.post('/mensaje', data: data);

      Message messsage = Message(id: '', name: '', email: '', message: '');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          messsage = MessageMapper.jsonToEntity(data);
        }
      }
      return messsage;
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<void> deleteMessage(String id) async {
    try {
      await dio.delete('/mensaje/$id');
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Message> getMessageById(String id) async {
    try {
      final response = await dio.get('/mensaje/$id');
      Message message = Message(id: '', name: '', email: '', message: '');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          message = MessageMapper.jsonToEntity(data);
        }
      }
      return message;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ServiceNotFound();
      throw e;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Message>> getMessagesByPage() async {
    try {
      final response = await dio.get('/mensaje');
      final List<Message> messages = [];
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is List) {
          for (final message in data) {
            if (message is Map<String, dynamic>) {
              messages.add(MessageMapper.jsonToEntity(message));
            }
          }
        }
      }
      return messages;
    } catch (e) {
      throw e;
    }
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
