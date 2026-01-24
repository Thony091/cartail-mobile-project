import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../providers/admin_password_form_provider.dart';

class AdminPasswordForm extends ConsumerWidget {
  final AdminPasswordFormArgs args;
  final ValueChanged<bool>? onSaved;

  const AdminPasswordForm({
    super.key,
    required this.args,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(adminPasswordFormProvider(args));
    final formNotifier = ref.read(adminPasswordFormProvider(args).notifier);

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header decorativo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFf39c12), Color(0xFFe67e22)],
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
                  child: const Icon(
                    Icons.lock_reset_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actualizar Contraseña',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (formState.userEmail != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          formState.userEmail!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Información de seguridad
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3498db).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF3498db),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'La contraseña debe tener al menos 6 caracteres',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF2c3e50),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Campo de contraseña mejorado
          ModernInputField(
            label: 'Nueva contraseña',
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

          // Indicador de fortaleza de contraseña
          if (formState.password.value.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PasswordStrengthIndicator(
              password: formState.password.value,
            ),
          ],

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

          // Botón de guardar mejorado
          SizedBox(
            width: double.infinity,
            child: ModernButton(
              text: formState.isPosting
                  ? 'Guardando...'
                  : 'Guardar contraseña',
              icon: formState.isPosting ? null : Icons.check_circle_outline,
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

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const _PasswordStrengthIndicator({required this.password});

  int get _strength {
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 10) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength;
  }

  Color get _color {
    if (_strength <= 1) return const Color(0xFFe74c3c);
    if (_strength <= 3) return const Color(0xFFf39c12);
    return const Color(0xFF27ae60);
  }

  String get _label {
    if (_strength <= 1) return 'Débil';
    if (_strength <= 3) return 'Media';
    return 'Fuerte';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < 4 ? 4 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index < _strength
                            ? _color
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _buildRequirements(),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7f8c8d),
          ),
        ),
      ],
    );
  }

  String _buildRequirements() {
    final requirements = <String>[];
    if (password.length < 6) requirements.add('mín. 6 caracteres');
    if (!RegExp(r'[A-Z]').hasMatch(password)) requirements.add('mayúscula');
    if (!RegExp(r'[0-9]').hasMatch(password)) requirements.add('número');
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      requirements.add('carácter especial');
    }

    if (requirements.isEmpty) {
      return '✓ Todos los requisitos cumplidos';
    }
    return 'Falta: ${requirements.join(', ')}';
  }
}
