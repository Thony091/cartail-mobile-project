import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../../presentation/presentation_container.dart';
import '../../../auth/presentation/providers/better_auth_provider.dart';

final changePasswordFormProvider = StateNotifierProvider.autoDispose<
    ChangePasswordFormNotifier, ChangePasswordFormState>((ref) {
  final authNotifier = ref.watch(betterAuthProvider.notifier);

  return ChangePasswordFormNotifier(
    changePassword: authNotifier.changePassword,
  );
});

class ChangePasswordFormNotifier extends StateNotifier<ChangePasswordFormState> {
  final Future<void> Function({
    required String currentPassword,
    required String newPassword,
  }) changePassword;

  ChangePasswordFormNotifier({
    required this.changePassword,
  }) : super(const ChangePasswordFormState());

  void onCurrentPasswordChange(String value) {
    final currentPassword = Password.dirty(value);
    state = state.copyWith(
      currentPassword: currentPassword,
      isFormValid: _validateForm(currentPassword),
      errorMessage: null,
    );
  }

  void onNewPasswordChange(String value) {
    final newPassword = Password.dirty(value);
    final confirmPassword = ConfirmPassword.dirty(
      password: value,
      value: state.confirmPassword.value,
    );
    state = state.copyWith(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
      isFormValid: _validateForm(
        state.currentPassword,
        newPassword,
        confirmPassword,
      ),
      errorMessage: null,
    );
  }

  void onConfirmPasswordChange(String value) {
    final confirmPassword = ConfirmPassword.dirty(
      password: state.newPassword.value,
      value: value,
    );
    state = state.copyWith(
      confirmPassword: confirmPassword,
      isFormValid: _validateForm(
        state.currentPassword,
        state.newPassword,
        confirmPassword,
      ),
      errorMessage: null,
    );
  }

  void toggleCurrentPasswordVisibility() {
    state = state.copyWith(
      isObscureCurrentPassword: !state.isObscureCurrentPassword,
    );
  }

  void toggleNewPasswordVisibility() {
    state = state.copyWith(
      isObscureNewPassword: !state.isObscureNewPassword,
    );
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isObscureConfirmPassword: !state.isObscureConfirmPassword,
    );
  }

  bool _validateForm(
    Password currentPassword, [
    Password? newPassword,
    ConfirmPassword? confirmPassword,
  ]) {
    return Formz.validate([
      currentPassword,
      newPassword ?? state.newPassword,
      confirmPassword ?? state.confirmPassword,
    ]);
  }

  Future<bool> onFormSubmit() async {
    _touchEveryField();
    if (!state.isFormValid) return false;

    state = state.copyWith(isPosting: true, errorMessage: null);

    try {
      await changePassword(
        currentPassword: state.currentPassword.value,
        newPassword: state.newPassword.value,
      );
      state = state.copyWith(isPosting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void _touchEveryField() {
    final currentPassword = Password.dirty(state.currentPassword.value);
    final newPassword = Password.dirty(state.newPassword.value);
    final confirmPassword = ConfirmPassword.dirty(
      password: state.newPassword.value,
      value: state.confirmPassword.value,
    );

    state = state.copyWith(
      isFormPosted: true,
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
      isFormValid: Formz.validate([
        currentPassword,
        newPassword,
        confirmPassword,
      ]),
    );
  }

  void reset() {
    state = const ChangePasswordFormState();
  }
}

class ChangePasswordFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isFormValid;
  final bool isObscureCurrentPassword;
  final bool isObscureNewPassword;
  final bool isObscureConfirmPassword;
  final Password currentPassword;
  final Password newPassword;
  final ConfirmPassword confirmPassword;
  final String? errorMessage;

  const ChangePasswordFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isFormValid = false,
    this.isObscureCurrentPassword = true,
    this.isObscureNewPassword = true,
    this.isObscureConfirmPassword = true,
    this.currentPassword = const Password.pure(),
    this.newPassword = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.errorMessage,
  });

  ChangePasswordFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isFormValid,
    bool? isObscureCurrentPassword,
    bool? isObscureNewPassword,
    bool? isObscureConfirmPassword,
    Password? currentPassword,
    Password? newPassword,
    ConfirmPassword? confirmPassword,
    String? errorMessage,
  }) {
    return ChangePasswordFormState(
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isFormValid: isFormValid ?? this.isFormValid,
      isObscureCurrentPassword:
          isObscureCurrentPassword ?? this.isObscureCurrentPassword,
      isObscureNewPassword: isObscureNewPassword ?? this.isObscureNewPassword,
      isObscureConfirmPassword:
          isObscureConfirmPassword ?? this.isObscureConfirmPassword,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      errorMessage: errorMessage,
    );
  }
}
