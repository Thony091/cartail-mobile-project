import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../shared/shared.dart';
import '../auth_provider.dart';


//! 3 - StateNotifierProvider - consume afuera
final resetPasswordFormProvider = StateNotifierProvider.autoDispose<ResetPasswordFormNotifier,ResetPasswordFormState>((ref) {

  final resetPasswordCallback = ref.watch( authProvider.notifier ).resetPasswordByEmail;

  return ResetPasswordFormNotifier(
    resetPasswordCallback:resetPasswordCallback
  );
});


//! 2 - Como implementamos un notifier
class ResetPasswordFormNotifier extends StateNotifier<ResetPasswordFormState> {

  final Function( String ) resetPasswordCallback;

  ResetPasswordFormNotifier({
    required this.resetPasswordCallback,
  }): super( ResetPasswordFormState() );
  
  onEmailChange( String value ) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([ newEmail ])
    );
  }

  Future<bool> onFormSubmit() async {

    try {
      
      _touchEveryField();

      if ( !state.isValid ) return false;

      state = state.copyWith(isPosting: true);

      await resetPasswordCallback( state.email.value );

      state = state.copyWith(isPosting: false);

      return true;

    } catch (e) {
      e.toString();
      return false;
    }
  }

  _touchEveryField() {

    final email    = Email.dirty(state.email.value);

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      isValid: Formz.validate([ email ])
    );

  }

}


//! 1 - State del provider
class ResetPasswordFormState {

  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Email email;

  ResetPasswordFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.email = const Email.pure(),
  });

  ResetPasswordFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Email? email,
  }) => ResetPasswordFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    email: email ?? this.email,
  );

  @override
  String toString() {
    return '''
  ResetPasswordFormState:
    isPosting: $isPosting
    isFormPosted: $isFormPosted
    isValid: $isValid
    email: $email
''';
  }
}
