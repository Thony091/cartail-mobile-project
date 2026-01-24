import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../../shared/presentation/shared/shared.dart';
import '../better_auth_provider.dart';

final authLoginFormProvider =
    StateNotifierProvider.autoDispose<AuthLoginFormNotifier, AuthLoginFormState>(
        (ref) {
  final authNotifier = ref.watch(betterAuthProvider.notifier);

  return AuthLoginFormNotifier(
    signIn: authNotifier.signIn,
    clearAuthError: authNotifier.clearError,
  );
});

class AuthLoginFormNotifier extends StateNotifier<AuthLoginFormState> {
  final Future<void> Function({
    required String email,
    required String password,
  }) signIn;
  final void Function() clearAuthError;

  AuthLoginFormNotifier({
    required this.signIn,
    required this.clearAuthError,
  }) : super(AuthLoginFormState());

  void onEmailChange(String value) {
    clearAuthError();
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([newEmail, state.password]),
    );
  }

  void onPasswordChanged(String value) {
    clearAuthError();
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([newPassword, state.email]),
    );
  }

  Future<bool> onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) return false;

    state = state.copyWith(isPosting: true);

    try {
      await signIn(
        email: state.email.value,
        password: state.password.value,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isPosting: false);
    }
  }

  void _touchEveryField() {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      password: password,
      isValid: Formz.validate([email, password]),
    );
  }

  bool changeObscurePassword(bool value) {
    state = state.copyWith(isObscurePassword: value);
    return value;
  }
}

class AuthLoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool isObscurePassword;
  final Email email;
  final Password password;

  AuthLoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.isObscurePassword = true,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
  });

  AuthLoginFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? isObscurePassword,
    Email? email,
    Password? password,
  }) =>
      AuthLoginFormState(
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        isObscurePassword: isObscurePassword ?? this.isObscurePassword,
        email: email ?? this.email,
        password: password ?? this.password,
      );

  @override
  String toString() {
    return '''
  AuthLoginFormState:
    isPosting: $isPosting
    isFormPosted: $isFormPosted
    isValid: $isValid
    isObscurePassword: $isObscurePassword
    email: $email
    password: $password
''';
  }
}
