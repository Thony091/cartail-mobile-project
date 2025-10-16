// ignore_for_file: use_rethrow_when_possible

import 'package:dio/dio.dart';
import 'package:portafolio_project/infrastructure/infrastructure.dart';

import '../../config/config.dart';
import '../../domain/domain.dart';

class MessageDatasourceImpl extends MessageDatasource{

  late final Dio dio;
  final String accessToken;

  MessageDatasourceImpl({
    required this.accessToken
  }) : dio = Dio(
    BaseOptions(
      baseUrl: Enviroment.baseUrl,
      headers: {
        'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
        'Authorization': 'Bearer $accessToken'
      }
    )
  );

  @override
  Future<Message> createUpdateMessage( String name, String email, String message ) async {
    
    try {
      final data = {
        'name': name,
        'email': email,
        'message': message
      };

      final response = await dio.post( '/message', data: data);

      Message messsage = Message(id: '', name: '', email: '', message: '');
      if ( response.statusCode == 200 ) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data') ){
          messsage = MessageMapper.jsonToEntity(data['data']);
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
      await dio.delete('/message/$id');
    } catch (e) {
      throw Exception();
    }

  }

  @override
  Future<Message> getMessageById(String id) async {
    try {
      final response = await dio.get('/message/$id');
      Message message = Message(id: '', name: '', email: '', message: '');
      if ( response.statusCode == 200 ) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data') ){
          message = MessageMapper.jsonToEntity(data['data']);
        }
      }
      return message;
    } on DioException catch (e) {
      if ( e.response!.statusCode == 404) throw ServiceNotFound();
      throw e;

    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Message>> getMessagesByPage() async {
    try {
      final response = await dio.get('/message');
      final List<Message> messages = [];
      if ( response.statusCode == 200 ) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data') ){
          var messagesData = data['data'];
          if (messagesData is List){
            for ( final message in messagesData ) {
              messages.add( MessageMapper.jsonToEntity(message) );
            }
          }
        }
      }
      return messages;
    } catch (e) {
      throw e;
    }
  }


}