import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:portafolio_project/features/auth/data/models/admin_response_models.dart';

import '../../../../shared/presentation/shared/shared.dart';
// import '../../data/models/admin_response_models.dart';
import '../../providers/admin_auth_provider.dart';

@immutable
class AdminUserFormArgs {
  final String userId;
  final String name;
  final String email;
  final String role;
  final bool isNewUser;

  const AdminUserFormArgs._({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.isNewUser,
  });

  const AdminUserFormArgs.create()
      : this._(
          userId: 'new',
          name: '',
          email: '',
          role: '',
          isNewUser: true,
        );

  AdminUserFormArgs.edit(AdminUserModel user)
      : this._(
          userId: user.id,
          name: user.name ?? '',
          email: user.email,
          role: user.role ?? '',
          isNewUser: false,
        );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminUserFormArgs &&
        other.userId == userId &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.isNewUser == isNewUser;
  }

  @override
  int get hashCode => Object.hash(userId, name, email, role, isNewUser);
}

final adminUserFormProvider = StateNotifierProvider.autoDispose
    .family<AdminUserFormNotifier, AdminUserFormState, AdminUserFormArgs>(
        (ref, args) {
  final adminUserNotifier = ref.watch(adminUserProvider.notifier);
  final adminUserState = ref.watch(adminUserProvider);

  return AdminUserFormNotifier(
    args: args,
    createUser: adminUserNotifier.createUser,
    updateUser: adminUserNotifier.updateUser,
    setRole: adminUserNotifier.setRole,
    getErrorMessage: () => adminUserState.errorMessage,
  );
});

class AdminUserFormNotifier extends StateNotifier<AdminUserFormState> {
  final Future<AdminUserModel?> Function({
    required String email,
    required String password,
    required String name,
    String? role,
    Map<String, dynamic>? data,
  }) createUser;
  final Future<AdminUserModel?> Function({
    required String userId,
    required Map<String, dynamic> data,
  }) updateUser;
  final Future<bool> Function({
    required String userId,
    required String role,
  }) setRole;
  final String? Function() getErrorMessage;

  AdminUserFormNotifier({
    required AdminUserFormArgs args,
    required this.createUser,
    required this.updateUser,
    required this.setRole,
    required this.getErrorMessage,
  }) : super(AdminUserFormState.fromArgs(args));

  void onNameChange(String value) {
    final name = Name.dirty(value);
    state = state.copyWith(
      name: name,
      isFormValid: _validate(name: name),
      errorMessage: null, // Limpiar error al escribir
    );
  }

  void onEmailChange(String value) {
    final email = Email.dirty(value);
    state = state.copyWith(
      email: email,
      isFormValid: _validate(email: email),
      errorMessage: null, // Limpiar error al escribir
    );
  }

  void onPasswordChange(String value) {
    final password = Password.dirty(value);
    state = state.copyWith(
      password: password,
      isFormValid: _validate(password: password),
      errorMessage: null, // Limpiar error al escribir
    );
  }

  void onRoleChange(String value) {
    state = state.copyWith(
      role: value,
      isFormValid: _validate(),
      errorMessage: null, // Limpiar error al escribir
    );
  }

  bool changeObscurePassword(bool value) {
    state = state.copyWith(isObscurePassword: value);
    return value;
  }

  Future<bool> onFormSubmit() async {
    _touchEveryField();
    if (!state.isFormValid) return false;

    state = state.copyWith(isPosting: true, errorMessage: null);

    try {
      if (state.isNewUser) {
        final result = await createUser(
          email: state.email.value.trim(),
          password: state.password.value,
          name: state.name.value.trim(),
          role: state.role.trim().isEmpty ? null : state.role.trim(),
        );

        if (result == null) {
          final errorMsg = getErrorMessage();
          state = state.copyWith(
            isPosting: false,
            errorMessage: errorMsg ?? 'Error al crear el usuario',
          );
          return false;
        }

        state = state.copyWith(isPosting: false);
        return true;
      }

      final updateData = <String, dynamic>{};
      if (state.name.value.trim().isNotEmpty &&
          state.name.value.trim() != state.initialName) {
        updateData['name'] = state.name.value.trim();
      }
      if (state.email.value.trim().isNotEmpty &&
          state.email.value.trim() != state.initialEmail) {
        updateData['email'] = state.email.value.trim();
      }

      bool updateOk = true;
      if (updateData.isNotEmpty) {
        final result = await updateUser(
          userId: state.userId,
          data: updateData,
        );
        updateOk = result != null;
      }

      bool roleOk = true;
      final roleTrimmed = state.role.trim();
      if (roleTrimmed.isNotEmpty && roleTrimmed != state.initialRole) {
        roleOk = await setRole(userId: state.userId, role: roleTrimmed);
      }

      final success = updateOk && roleOk;

      if (!success) {
        final errorMsg = getErrorMessage();
        state = state.copyWith(
          isPosting: false,
          errorMessage: errorMsg ?? 'Error al actualizar el usuario',
        );
        return false;
      }

      state = state.copyWith(isPosting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
      return false;
    }
  }

  void _touchEveryField() {
    final name = Name.dirty(state.name.value);
    final email = Email.dirty(state.email.value);
    final password = state.isNewUser
        ? Password.dirty(state.password.value)
        : state.password;

    state = state.copyWith(
      isFormPosted: true,
      name: name,
      email: email,
      password: password,
      isFormValid: _validate(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  bool _validate({
    Name? name,
    Email? email,
    Password? password,
  }) {
    final nameValue = name ?? state.name;
    final emailValue = email ?? state.email;

    if (state.isNewUser) {
      final passwordValue = password ?? state.password;
      return Formz.validate([nameValue, emailValue, passwordValue]);
    }

    return Formz.validate([nameValue, emailValue]);
  }
}

class AdminUserFormState {
  final String userId;
  final bool isNewUser;
  final bool isPosting;
  final bool isFormPosted;
  final bool isFormValid;
  final bool isObscurePassword;
  final Name name;
  final Email email;
  final Password password;
  final String role;
  final String initialName;
  final String initialEmail;
  final String initialRole;
  final String? errorMessage;

  const AdminUserFormState({
    required this.userId,
    required this.isNewUser,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.initialName,
    required this.initialEmail,
    required this.initialRole,
    this.isPosting = false,
    this.isFormPosted = false,
    this.isFormValid = false,
    this.isObscurePassword = true,
    this.errorMessage,
  });

  factory AdminUserFormState.fromArgs(AdminUserFormArgs args) {
    return AdminUserFormState(
      userId: args.userId,
      isNewUser: args.isNewUser,
      name: Name.dirty(args.name),
      email: Email.dirty(args.email),
      password: const Password.pure(),
      role: args.role,
      initialName: args.name,
      initialEmail: args.email,
      initialRole: args.role,
    );
  }

  AdminUserFormState copyWith({
    String? userId,
    bool? isNewUser,
    bool? isPosting,
    bool? isFormPosted,
    bool? isFormValid,
    bool? isObscurePassword,
    Name? name,
    Email? email,
    Password? password,
    String? role,
    String? initialName,
    String? initialEmail,
    String? initialRole,
    String? errorMessage,
  }) {
    return AdminUserFormState(
      userId: userId ?? this.userId,
      isNewUser: isNewUser ?? this.isNewUser,
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isFormValid: isFormValid ?? this.isFormValid,
      isObscurePassword: isObscurePassword ?? this.isObscurePassword,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      initialName: initialName ?? this.initialName,
      initialEmail: initialEmail ?? this.initialEmail,
      initialRole: initialRole ?? this.initialRole,
      errorMessage: errorMessage,
    );
  }
}
