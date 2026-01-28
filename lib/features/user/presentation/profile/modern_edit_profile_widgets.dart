import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../providers/change_password_form_provider.dart';

class EditProfileAvatarSection extends StatelessWidget {
  final VoidCallback onChangeAvatar;
  final String? currentImageUrl;

  const EditProfileAvatarSection({
    super.key,
    required this.onChangeAvatar,
    this.currentImageUrl,
  });

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
                  child: currentImageUrl != null && currentImageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            currentImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              );
                            },
                          ),
                        )
                      : const Icon(
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

class EditProfileInfoSection extends StatefulWidget {
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
  State<EditProfileInfoSection> createState() => _EditProfileInfoSectionState();
}

class _EditProfileInfoSectionState extends State<EditProfileInfoSection> {
  late bool _hasChanges;

  @override
  void initState() {
    super.initState();
    _hasChanges = false;
    widget.nameController.addListener(_updateChangeStatus);
    widget.rutController.addListener(_updateChangeStatus);
    widget.birthdayController.addListener(_updateChangeStatus);
    widget.phoneController.addListener(_updateChangeStatus);
    widget.bioController.addListener(_updateChangeStatus);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_updateChangeStatus);
    widget.rutController.removeListener(_updateChangeStatus);
    widget.birthdayController.removeListener(_updateChangeStatus);
    widget.phoneController.removeListener(_updateChangeStatus);
    widget.bioController.removeListener(_updateChangeStatus);
    super.dispose();
  }

  void _updateChangeStatus() {
    setState(() {
      _hasChanges = widget.nameController.text.isNotEmpty ||
          widget.rutController.text.isNotEmpty ||
          widget.birthdayController.text.isNotEmpty ||
          widget.phoneController.text.isNotEmpty ||
          widget.bioController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                if (_hasChanges)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF39c12).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info,
                          size: 14,
                          color: Color(0xFFF39c12),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Con cambios',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF39c12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            ModernInputField(
              controller: widget.nameController,
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
              controller: widget.rutController,
              label: 'RUT',
              prefixIcon: const Icon(Icons.badge),
              hint: 'XX.XXX.XXX-X',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El RUT es requerido';
                }
                // Validación básica de RUT chileno
                final rutRegex = RegExp(r'^\d{1,2}\.\d{3}\.\d{3}-[0-9Kk]$');
                if (!rutRegex.hasMatch(value ?? '')) {
                  return 'Formato de RUT inválido (XX.XXX.XXX-X)';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            ModernInputField(
              controller: widget.birthdayController,
              label: 'Fecha de Nacimiento',
              prefixIcon: const Icon(Icons.calendar_today),
              hint: 'DD/MM/YYYY',
              readOnly: true,
              onTap: widget.onSelectBirthday,
              suffixIcon: const Icon(
                Icons.date_range,
                color: Color(0xFF3498db),
              ),
            ),

            const SizedBox(height: 20),

            ModernInputField(
              controller: widget.phoneController,
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
              controller: widget.bioController,
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

class AvatarSelectionSheet extends StatefulWidget {
  const AvatarSelectionSheet({super.key});

  @override
  State<AvatarSelectionSheet> createState() => _AvatarSelectionSheetState();
}

class _AvatarSelectionSheetState extends State<AvatarSelectionSheet> {
  bool _isLoading = false;

  void _handleCameraCapture() async {
    setState(() => _isLoading = true);
    // TODO: Implementar captura de cámara usando image_picker
    // Ejemplo:
    // final picker = ImagePicker();
    // final pickedFile = await picker.pickImage(source: ImageSource.camera);
    // if (pickedFile != null) {
    //   // Procesar imagen
    // }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidad de cámara no implementada'),
          backgroundColor: Color(0xFFF39c12),
        ),
      );
    }
  }

  void _handleGallerySelection() async {
    setState(() => _isLoading = true);
    // TODO: Implementar selección de galería usando image_picker
    // Ejemplo:
    // final picker = ImagePicker();
    // final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    // if (pickedFile != null) {
    //   // Procesar imagen
    // }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidad de galería no implementada'),
          backgroundColor: Color(0xFFF39c12),
        ),
      );
    }
  }

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
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleCameraCapture,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Seleccionar de Galería',
            style: ModernButtonStyle.secondary,
            icon: Icons.photo_library,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleGallerySelection,
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

    // Limpiar campos cuando se abre el dialog
    Future.microtask(() {
      final notifier = ref.read(changePasswordFormProvider.notifier);
      notifier.reset();
    });
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
