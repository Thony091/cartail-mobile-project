import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../providers/admin_user_form_provider.dart';

class AdminUserForm extends ConsumerWidget {
  final AdminUserFormArgs args;
  final ValueChanged<bool>? onSaved;
  final bool showTitle;

  const AdminUserForm({
    super.key,
    required this.args,
    this.onSaved,
    this.showTitle = true,
  });

  static const List<String> _roles = [
    'admin',
    'operator',
    'user',
    'guest',
  ];

  static const Map<String, IconData> _roleIcons = {
    'admin': Icons.admin_panel_settings_outlined,
    'operator': Icons.engineering_outlined,
    'user': Icons.person_outline,
    'guest': Icons.visibility_outlined,
  };

  static const Map<String, Color> _roleColors = {
    'admin': Color(0xFFe74c3c),
    'operator': Color(0xFF9b59b6),
    'user': Color(0xFF3498db),
    'guest': Color(0xFF95a5a6),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(adminUserFormProvider(args));
    final formNotifier = ref.read(adminUserFormProvider(args).notifier);
    final roles = [..._roles];
    if (formState.role.isNotEmpty && !roles.contains(formState.role)) {
      roles.add(formState.role);
    }

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header decorativo
          if (showTitle)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: formState.isNewUser
                      ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
                      : [const Color(0xFF3498db), const Color(0xFF2980b9)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      formState.isNewUser
                          ? Icons.person_add_outlined
                          : Icons.edit_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      formState.isNewUser ? 'Crear Usuario' : 'Editar Usuario',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (showTitle) const SizedBox(height: 24),

          // Campo de nombre
          ModernInputField(
            label: 'Nombre completo',
            hint: 'Ej: Juan Pérez',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3498db).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 20,
                color: Color(0xFF3498db),
              ),
            ),
            initialValue: (formState.name.value.isNotEmpty) ? formState.name.value : null,
            onChanged: formNotifier.onNameChange,
            errorMessage:
                formState.isFormPosted ? formState.name.errorMessage : null,
          ),

          const SizedBox(height: 16),

          // Campo de email
          ModernInputField(
            label: 'Correo Electrónico',
            hint: 'usuario@correo.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF27ae60).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 20,
                color: Color(0xFF27ae60),
              ),
            ),
            initialValue: formState.email.value,
            onChanged: formNotifier.onEmailChange,
            errorMessage:
                formState.isFormPosted ? formState.email.errorMessage : null,
          ),

          // Campo de contraseña (solo para nuevos usuarios)
          if (formState.isNewUser) ...[
            const SizedBox(height: 16),
            ModernInputField(
              label: 'Contraseña',
              hint: 'Mínimo 6 caracteres',
              obscureText: formState.isObscurePassword,
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFf39c12).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: Color(0xFFf39c12),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  !formState.isObscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF7f8c8d),
                ),
                onPressed: () => formNotifier
                    .changeObscurePassword(!formState.isObscurePassword),
                tooltip: formState.isObscurePassword
                    ? 'Mostrar contraseña'
                    : 'Ocultar contraseña',
              ),
              onChanged: formNotifier.onPasswordChange,
              errorMessage: formState.isFormPosted
                  ? formState.password.errorMessage
                  : null,
            ),
          ],

          const SizedBox(height: 24),

          // Selector de rol mejorado
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9b59b6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: Color(0xFF9b59b6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Rol del Usuario',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: roles.map((role) {
                  final isSelected = formState.role == role;
                  final color = _roleColors[role] ?? const Color(0xFF95a5a6);
                  final icon = _roleIcons[role] ?? Icons.person_outline;

                  return _RoleChip(
                    role: role,
                    icon: icon,
                    color: color,
                    isSelected: isSelected,
                    onTap: () => formNotifier.onRoleChange(role),
                  );
                }).toList(),
              ),
            ],
          ),

          // Mostrar error si existe
          if (formState.errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFe74c3c).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFe74c3c).withValues(alpha: 0.3),
                ),
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
                        fontSize: 13,
                        color: Color(0xFFe74c3c),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Botón de guardar
          SizedBox(
            width: double.infinity,
            child: ModernButton(
              text: formState.isPosting
                  ? (formState.isNewUser ? 'Creando...' : 'Guardando...')
                  : (formState.isNewUser ? 'Crear Usuario' : 'Guardar Cambios'),
              icon: formState.isPosting
                  ? null
                  : formState.isNewUser
                      ? Icons.person_add_outlined
                      : Icons.check_circle_outline,
              isLoading: formState.isPosting,
              onPressed: formState.isPosting
                  ? null
                  : () async {
                      final ok = await formNotifier.onFormSubmit();
                      if (!context.mounted) return;

                      // Solo llamar onSaved si fue exitoso
                      if (ok) {
                        onSaved?.call(ok);
                      }
                      // Si hay error, no cerrar el modal, el error ya se muestra arriba
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.role,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? color : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                role.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: color,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
