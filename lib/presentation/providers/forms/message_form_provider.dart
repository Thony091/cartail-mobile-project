import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../presentation_container.dart';

final messageFormProvider = StateNotifierProvider.autoDispose<MessageFormNotifier, MessageFormState>((ref) {

  final postMessageCallback = ref.watch( messagesProvider.notifier ).postMessage;

  return MessageFormNotifier(
    postMessageCallback: postMessageCallback
  );
});


class MessageFormNotifier extends StateNotifier<MessageFormState>{

  final Function(String, String, String) postMessageCallback;

  MessageFormNotifier({
    required this.postMessageCallback,
  }): super( MessageFormState() );

  onNameChange( String value ) {
    final newName = Name.dirty(value);
    state = state.copyWith(
      name: newName,
      isValid: Formz.validate([ newName, state.name ])
    );
  }

  onEmailChange( String value ) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([ newEmail, state.email ])
    );
  }

  onMessageChange( String value ) {
    final newMessage = Messages.dirty(value);
    state = state.copyWith(
      message: newMessage,
      isValid: Formz.validate([ newMessage, state.message ])
    );
  }

  onResponseChange( String value ) {
    final newResponse = Messages.dirty(value);
    state = state.copyWith(
      reply: newResponse,
      isValid: Formz.validate([ newResponse, state.reply ])
    );
  }

  Future<bool> postMessage() async {

    try {

      _touchEveryField();
      
      if ( !state.isValid ) return false;

      state = state.copyWith( isPosting: true );
      
      await postMessageCallback(
         state.name.value,
         state.email.value,
         state.message.value
      );
      if (!mounted) return false;  // Verifica si el StateNotifier está montado
      state = state.copyWith( isPosting: false, );
      
      return true;

    } catch (e) {
            e.toString();
      return false;
    }
  }

  _touchEveryField() {

    final name     = Name.dirty(state.name.value);
    final email    = Email.dirty(state.email.value);
    final message  = Messages.dirty(state.message.value);

    state = state.copyWith(
      isFormPosted: true,
      name    : name,
      email   : email,
      message : message,
      isValid : Formz.validate([ 
        name, 
        email, 
        message
      ])
    );
  }

}

class MessageFormState{
  
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Name name;
  final Email email;
  final Messages message;
  final Messages reply;

  MessageFormState({
    this.isPosting      = false,
    this.isFormPosted   = false,
    this.isValid        = false,
    this.name           = const Name.pure(),
    this.email          = const Email.pure(),
    this.message        = const Messages.pure(),
    this.reply          = const Messages.pure()
  });

  MessageFormState copyWith({
    bool?       isPosting,
    bool?       isFormPosted,
    bool?       isValid,
    Name?       name,
    Email?      email,
    Messages?    message,
    Messages?    reply,
  }) => MessageFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    name: name ?? this.name,
    email: email ?? this.email,
    message: message ?? this.message,
    reply: reply ?? this.reply,
  );

}