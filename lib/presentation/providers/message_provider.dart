import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';
import '../presentation_container.dart';

final messageProvider = StateNotifierProvider.family<MessageNotifier, MessageState, String>(
  (ref, messageId) {

    final messageRepository = MessageRepositoryImpl( 
      MessageDatasourceImpl(accessToken: ref.watch( authProvider ).token)
    );

    return MessageNotifier(
      messageRepository: messageRepository,
      messageId: messageId
    );
  }
);

class MessageNotifier extends StateNotifier<MessageState>{

  final MessageRepository messageRepository;

  MessageNotifier({
    required this.messageRepository,
    required String messageId,
  }) : super( MessageState( id: messageId )){
    getService();
  }

  Future<void> getService() async {

    try {
        
      final message = await messageRepository.getMessageById(state.id);
      
      state = state.copyWith(
        message: message,
        isLoading: false
      );  

    } catch (e) {
      print('Error al obtener el mensaje: $e');
    }
  }
  

}

class MessageState {

  final String id;
  final Message? message;
  final bool isLoading;
  final bool isSaving;

  MessageState({
    required this.id,
    this.message,
    this.isLoading = true,
    this.isSaving = false,
  });

  MessageState copyWith({
    String? id,
    Message? message,
    bool? isLoading,
    bool? isSaving,
  }) => MessageState(
      id: id ?? this.id,
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  
}