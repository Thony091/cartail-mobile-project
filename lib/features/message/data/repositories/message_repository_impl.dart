import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_datasources.dart';

class MessageRepositoryImpl extends MessageRepository {
  
  final MessageDatasource messageDatasource;

  MessageRepositoryImpl(this.messageDatasource);
  
  @override
  Future<Message> createUpdateMessage( String name, String email, String message) {
    return messageDatasource.createUpdateMessage( name, email, message );
  }
  
  @override
  Future<void> deleteMessage(String id) {
    return messageDatasource.deleteMessage(id);
  }
  
  @override
  Future<Message> getMessageById(String id) {
    return messageDatasource.getMessageById(id);
  }
  
  @override
  Future<List<Message>> getMessagesByPage() {
    return messageDatasource.getMessagesByPage();
  }


}