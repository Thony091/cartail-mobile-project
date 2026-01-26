import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../providers/change_password_form_provider.dart';

class EditProfileAvatarSection extends StatelessWidget {
  final VoidCallback onChangeAvatar;

  const EditProfileAvatarSection({super.key, required this.onChangeAvatar});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: ModernCard(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3498db), Color(0xFF2980b9)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3498db).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onChangeAvatar,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFf39c12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Toca el ícono para cambiar tu foto',
              style: TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileInfoSection extends StatelessWidget {
  // Controllers
  final TextEditingController nameController;
  final TextEditingController rutController;
  final TextEditingController birthdayController;
  final TextEditingController phoneController;
  final TextEditingController bioController;

  // Callbacks
  final VoidCallback onSelectBirthday;

  const EditProfileInfoSection({
    super.key,
    required this.nameController,
    required this.rutController,
    required this.birthdayController,
    required this.phoneController,
    required this.bioController,
    required this.onSelectBirthday,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 20),

            ModernInputField(
              controller: nameController,
              label: 'Nombre Completo',
              prefixIcon: const Icon(Icons.person),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            ModernInputField(
              controller: rutController,
              label: 'RUT',
              prefixIcon: const Icon(Icons.badge),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El RUT es requerido';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            ModernInputField(
              controller: birthdayController,
              label: 'Fecha de Nacimiento',
              prefixIcon: const Icon(Icons.calendar_today),
              readOnly: true,
              onTap: onSelectBirthday,
            ),

            const SizedBox(height: 20),

            ModernInputField(
              controller: phoneController,
              label: 'Número de Teléfono',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El teléfono es requerido';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            ModernInputField(
              controller: bioController,
              label: 'Biografía',
              hint: 'Cuéntanos algo sobre ti...',
              maxLines: 4,
              prefixIcon: const Icon(Icons.info),
            ),
          ],
        ),
      ),
    );
  }
}

class AvatarSelectionSheet extends StatelessWidget {
  const AvatarSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Cambiar Foto de Perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 20),
          ModernButton(
            text: 'Tomar Foto',
            icon: Icons.camera_alt,
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar cámara
            },
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Seleccionar de Galería',
            style: ModernButtonStyle.secondary,
            icon: Icons.photo_library,
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar galería
            },
          ),
        ],
      ),
    );
  }
}

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final notifier = ref.read(changePasswordFormProvider.notifier);
    final success = await notifier.onFormSubmit();

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña cambiada correctamente'),
          backgroundColor: Color(0xFF27ae60),
        ),
      );
      // Reset form for next use
      notifier.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(changePasswordFormProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Cambiar Contraseña',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                // Divider
                const Divider(height: 1),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Current Password Field
                      ModernInputField(
                        label: 'Contraseña Actual',
                        controller: _currentPasswordController,
                        obscureText: formState.isObscureCurrentPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            formState.isObscureCurrentPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF7f8c8d),
                          ),
                          onPressed: () {
                            ref
                                .read(changePasswordFormProvider.notifier)
                                .toggleCurrentPasswordVisibility();
                          },
                        ),
                        errorMessage: formState.isFormPosted
                            ? formState.currentPassword.errorMessage
                            : null,
                        onChanged: (value) {
                          ref
                              .read(changePasswordFormProvider.notifier)
                              .onCurrentPasswordChange(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      // New Password Field
                      ModernInputField(
                        label: 'Nueva Contraseña',
                        controller: _newPasswordController,
                        obscureText: formState.isObscureNewPassword,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            formState.isObscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF7f8c8d),
                          ),
                          onPressed: () {
                            ref
                                .read(changePasswordFormProvider.notifier)
                                .toggleNewPasswordVisibility();
                          },
                        ),
                        errorMessage: formState.isFormPosted
                            ? formState.newPassword.errorMessage
                            : null,
                        onChanged: (value) {
                          ref
                              .read(changePasswordFormProvider.notifier)
                              .onNewPasswordChange(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password Field
                      ModernInputField(
                        label: 'Confirmar Contraseña',
                        controller: _confirmPasswordController,
                        obscureText: formState.isObscureConfirmPassword,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            formState.isObscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF7f8c8d),
                          ),
                          onPressed: () {
                            ref
                                .read(changePasswordFormProvider.notifier)
                                .toggleConfirmPasswordVisibility();
                          },
                        ),
                        errorMessage: formState.isFormPosted
                            ? formState.confirmPassword.errorMessage
                            : null,
                        onChanged: (value) {
                          ref
                              .read(changePasswordFormProvider.notifier)
                              .onConfirmPasswordChange(value);
                        },
                      ),
                      // Backend Error Message
                      if (formState.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFe74c3c)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: const Color(0xFFe74c3c)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFe74c3c),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  formState.errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFe74c3c),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Divider
                const Divider(height: 1),
                // Actions
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: formState.isPosting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ModernButton(
                        text: formState.isPosting ? 'Enviando...' : 'Cambiar',
                        isLoading: formState.isPosting,
                        onPressed: formState.isPosting ||
                                !formState.isFormValid
                            ? null
                            : _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuccesUpdateDialog extends StatelessWidget {
  const SuccesUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF27ae60).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF27ae60),
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Cuenta Creada!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu cuenta ha sido creada exitosamente. Ahora puedes iniciar sesión.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
          ),
        ],
      ),
      actions: [
        ModernButton(
          text: 'Continuar',
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Volver a login
          },
        ),
      ],
    );
  }
}
