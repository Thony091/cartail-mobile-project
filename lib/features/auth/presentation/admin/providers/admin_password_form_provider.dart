import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../../shared/presentation/shared/shared.dart';
import '../../providers/admin_auth_provider.dart';

class AdminPasswordFormArgs {
  final String userId;
  final String? userEmail;

  const AdminPasswordFormArgs({
    required this.userId,
    this.userEmail,
  });
}

final adminPasswordFormProvider = StateNotifierProvider.autoDispose.family<
    AdminPasswordFormNotifier, AdminPasswordFormState, AdminPasswordFormArgs>(
  (ref, args) {
    final adminUserNotifier = ref.watch(adminUserProvider.notifier);
    final adminUserState = ref.watch(adminUserProvider);

    return AdminPasswordFormNotifier(
      args: args,
      setPassword: adminUserNotifier.setPassword,
      getErrorMessage: () => adminUserState.errorMessage,
    );
  },
);

class AdminPasswordFormNotifier extends StateNotifier<AdminPasswordFormState> {
  final Future<bool> Function({
    required String userId,
    required String newPassword,
  }) setPassword;
  final String? Function() getErrorMessage;

  AdminPasswordFormNotifier({
    required AdminPasswordFormArgs args,
    required this.setPassword,
    required this.getErrorMessage,
  }) : super(AdminPasswordFormState.fromArgs(args));

  void onPasswordChange(String value) {
    final password = Password.dirty(value);
    state = state.copyWith(
      password: password,
      isFormValid: Formz.validate([password]),
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
      final success = await setPassword(
        userId: state.userId,
        newPassword: state.password.value,
      );

      if (!success) {
        // Obtener el mensaje de error del provider
        final errorMsg = getErrorMessage();
        state = state.copyWith(
          isPosting: false,
          errorMessage: errorMsg ?? 'Error al actualizar la contraseña',
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
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      password: password,
      isFormValid: Formz.validate([password]),
    );
  }
}

class AdminPasswordFormState {
  final String userId;
  final String? userEmail;
  final bool isPosting;
  final bool isFormPosted;
  final bool isFormValid;
  final bool isObscurePassword;
  final Password password;
  final String? errorMessage;

  const AdminPasswordFormState({
    required this.userId,
    this.userEmail,
    this.isPosting = false,
    this.isFormPosted = false,
    this.isFormValid = false,
    this.isObscurePassword = true,
    this.password = const Password.pure(),
    this.errorMessage,
  });

  factory AdminPasswordFormState.fromArgs(AdminPasswordFormArgs args) {
    return AdminPasswordFormState(
      userId: args.userId,
      userEmail: args.userEmail,
    );
  }

  AdminPasswordFormState copyWith({
    String? userId,
    String? userEmail,
    bool? isPosting,
    bool? isFormPosted,
    bool? isFormValid,
    bool? isObscurePassword,
    Password? password,
    String? errorMessage,
  }) {
    return AdminPasswordFormState(
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isFormValid: isFormValid ?? this.isFormValid,
      isObscurePassword: isObscurePassword ?? this.isObscurePassword,
      password: password ?? this.password,
      errorMessage: errorMessage,
    );
  }
}
