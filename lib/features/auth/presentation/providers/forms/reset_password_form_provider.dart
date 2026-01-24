import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../../shared/presentation/shared/shared.dart';
import '../better_auth_provider.dart';

final authResetPasswordFormProvider = StateNotifierProvider.autoDispose<
    AuthResetPasswordFormNotifier, AuthResetPasswordFormState>((ref) {
  final authNotifier = ref.watch(betterAuthProvider.notifier);

  return AuthResetPasswordFormNotifier(
    sendResetEmail: authNotifier.sendPasswordResetEmail,
    clearAuthError: authNotifier.clearError,
  );
});

class AuthResetPasswordFormNotifier
    extends StateNotifier<AuthResetPasswordFormState> {
  final Future<void> Function(String email) sendResetEmail;
  final void Function() clearAuthError;

  AuthResetPasswordFormNotifier({
    required this.sendResetEmail,
    required this.clearAuthError,
  }) : super(AuthResetPasswordFormState());

  void onEmailChange(String value) {
    clearAuthError();
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([newEmail]),
    );
  }

  Future<bool> onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) return false;

    state = state.copyWith(isPosting: true);

    try {
      await sendResetEmail(state.email.value);
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isPosting: false);
    }
  }

  void _touchEveryField() {
    final email = Email.dirty(state.email.value);

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      isValid: Formz.validate([email]),
    );
  }
}

class AuthResetPasswordFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Email email;

  AuthResetPasswordFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.email = const Email.pure(),
  });

  AuthResetPasswordFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Email? email,
  }) =>
      AuthResetPasswordFormState(
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        email: email ?? this.email,
      );

  @override
  String toString() {
    return '''
  AuthResetPasswordFormState:
    isPosting: $isPosting
    isFormPosted: $isFormPosted
    isValid: $isValid
    email: $email
''';
  }
}
