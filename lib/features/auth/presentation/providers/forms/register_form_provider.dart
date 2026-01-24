import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../../shared/presentation/shared/shared.dart';
import '../better_auth_provider.dart';

final authRegisterFormProvider = StateNotifierProvider.autoDispose<
    AuthRegisterFormNotifier, AuthRegisterFormState>((ref) {
  final authNotifier = ref.watch(betterAuthProvider.notifier);

  return AuthRegisterFormNotifier(
    signUp: authNotifier.signUp,
    clearAuthError: authNotifier.clearError,
  );
});

class AuthRegisterFormNotifier extends StateNotifier<AuthRegisterFormState> {
  final Future<void> Function({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? rut,
    String? birthday,
  }) signUp;
  final void Function() clearAuthError;

  AuthRegisterFormNotifier({
    required this.signUp,
    required this.clearAuthError,
  }) : super(AuthRegisterFormState());

  void onNameChange(String value) {
    clearAuthError();
    final newName = Name.dirty(value);
    state = state.copyWith(
      name: newName,
      isValid: _validate(name: newName),
    );
  }

  void onRutChange(String value) {
    clearAuthError();
    final newRut = Rut.dirty(value);
    state = state.copyWith(
      rut: newRut,
      isValid: _validate(rut: newRut),
    );
  }

  void onBirthayChange(String value) {
    clearAuthError();
    final newBirthday = Birthday.dirty(value);
    state = state.copyWith(
      birthday: newBirthday,
      isValid: _validate(birthday: newBirthday),
    );
  }

  void onEmailChange(String value) {
    clearAuthError();
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: _validate(email: newEmail),
    );
  }

  void onPhoneChange(String value) {
    clearAuthError();
    final newPhone = Phone.dirty(value);
    state = state.copyWith(
      phone: newPhone,
      isValid: _validate(phone: newPhone),
    );
  }

  void onPasswordChanged(String value) {
    clearAuthError();
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: _validate(password: newPassword),
    );
  }

  void onObscurePasswordChanged(bool value) {
    state = state.copyWith(
      isObscurePassword: value,
    );
  }

  Future<bool> onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) return false;

    state = state.copyWith(isPosting: true);

    try {
      await signUp(
        email: state.email.value,
        password: state.password.value,
        name: state.name.value,
        phone: state.phone.value,
        rut: state.rut.value,
        birthday: state.birthday.value,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isPosting: false);
    }
  }

  void _touchEveryField() {
    final name = Name.dirty(state.name.value);
    final rut = Rut.dirty(state.rut.value);
    final birthday = Birthday.dirty(state.birthday.value);
    final email = Email.dirty(state.email.value);
    final phone = Phone.dirty(state.phone.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      name: name,
      rut: rut,
      birthday: birthday,
      email: email,
      phone: phone,
      password: password,
      isValid: Formz.validate([
        name,
        rut,
        birthday,
        email,
        phone,
        password,
      ]),
    );
  }

  bool _validate({
    Name? name,
    Rut? rut,
    Birthday? birthday,
    Email? email,
    Phone? phone,
    Password? password,
  }) {
    return Formz.validate([
      name ?? state.name,
      rut ?? state.rut,
      birthday ?? state.birthday,
      email ?? state.email,
      phone ?? state.phone,
      password ?? state.password,
    ]);
  }
}

class AuthRegisterFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool isObscurePassword;
  final Name name;
  final Rut rut;
  final Birthday birthday;
  final Email email;
  final Phone phone;
  final Password password;

  AuthRegisterFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.isObscurePassword = true,
    this.name = const Name.pure(),
    this.rut = const Rut.pure(),
    this.birthday = const Birthday.pure(),
    this.email = const Email.pure(),
    this.phone = const Phone.pure(),
    this.password = const Password.pure(),
  });

  AuthRegisterFormState copyWith({
    bool? isObscurePassword,
    bool? isFormPosted,
    bool? isPosting,
    bool? isValid,
    Name? name,
    Rut? rut,
    Birthday? birthday,
    Email? email,
    Phone? phone,
    Password? password,
  }) =>
      AuthRegisterFormState(
        isObscurePassword: isObscurePassword ?? this.isObscurePassword,
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        name: name ?? this.name,
        rut: rut ?? this.rut,
        birthday: birthday ?? this.birthday,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        password: password ?? this.password,
      );

  @override
  String toString() {
    return '''
      AuthRegisterFormState:
        obscurePassword: $isObscurePassword
        isPosting: $isPosting
        isFormPosted: $isFormPosted
        isValid: $isValid
        name: $name
        rut: $rut
        birthday: $birthday
        email: $email
        phone: $phone
        password: $password
    ''';
  }
}
