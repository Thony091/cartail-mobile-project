
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';
import '../presentation_container.dart';

final messagesProvider = StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {

  final messageRepository = MessageRepositoryImpl( MessageDatasourceImpl(accessToken: ref.watch( authProvider ).token) );

  return MessagesNotifier(
    messageRepository: messageRepository,
  );
});


class MessagesNotifier extends StateNotifier<MessagesState>{

  final MessageRepository messageRepository;

  MessagesNotifier({
    required this.messageRepository,
  }): super(MessagesState( )){
    getMessages();
  }

  Future<void> postMessage(String name, String email, String message) async{

    try {

      final messsage = await messageRepository.createUpdateMessage(name, email, message);

      state = state.copyWith(
        message: messsage
      );

    } on CustomError catch(e){
      state = state.copyWith(
        errorMessage: e.message
      );
    }
  }

  Future<void> getMessages() async {
    
    state = state.copyWith(isLoading: true);

    try {
      
      final messages = await messageRepository.getMessagesByPage();
      
      state = state.copyWith(
        messages: messages,
        isLoading: false
      );

    } catch (e) {
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al obtener los servicios'
      );

    }
  }

  Future<void> deleteMessage( String id ) async {

    try {
      
      await messageRepository.deleteMessage(id);
      state = state.copyWith(
        messages: state.messages.where((element) => element.id != id).toList()
      );

    } catch (e) {
      print(e);
    }

  }

}

class MessagesState{
  
  final bool isLoading;
  final Message? message;
  final List<Message> messages;
  final String errorMessage;

  MessagesState({
    this.errorMessage = '',
    this.messages     = const [],
    this.isLoading    = false,
    this.message,
  });

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    Message? message,
    String? errorMessage
  }) => MessagesState(
    messages: messages ?? this.messages,
    isLoading: isLoading ?? this.isLoading,
    message: message ?? this.message,
    errorMessage: errorMessage ?? this.errorMessage
  );

}