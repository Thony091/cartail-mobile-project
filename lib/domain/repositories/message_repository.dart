import '../domain.dart';

abstract class MessageRepository{
  
  Future<List<Message>> getMessagesByPage();
  Future<Message> getMessageById( String id );
  Future<Message> createUpdateMessage( String name, String email, String message);
  Future<void> deleteMessage( String id );
  
}