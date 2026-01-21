import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';

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
                        color: const Color(0xFF3498db).withOpacity(0.3),
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

class ChangePasswordDialog extends ConsumerWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Cambiar Contraseña'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModernInputField(
            label: 'Contraseña Actual',
            obscureText: true,
            prefixIcon: Icon(Icons.lock_outline),
          ),
          SizedBox(height: 16),
          ModernInputField(
            label: 'Nueva Contraseña',
            obscureText: true,
            prefixIcon: Icon(Icons.lock),
          ),
          SizedBox(height: 16),
          ModernInputField(
            label: 'Confirmar Contraseña',
            obscureText: true,
            prefixIcon: Icon(Icons.lock),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ModernButton(
          text: 'Cambiar',
          onPressed: () {
            // Validar y cambiar contraseña
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contraseña cambiada correctamente'),
                backgroundColor: Color(0xFF27ae60),
              ),
            );
          },
        ),
      ],
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
              color: const Color(0xFF27ae60).withOpacity(0.1),
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
