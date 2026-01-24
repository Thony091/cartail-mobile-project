import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/better_auth_provider.dart';
import '../providers/forms/reset_password_form_provider.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';

class ResetPasswordHeader extends StatelessWidget {
  const ResetPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2c3e50), Color(0xFF34495e)],
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset, color: Colors.white, size: 50),
        ),
        const SizedBox(height: 24),
        const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'No te preocupes, te ayudamos a recuperarla',
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ResetPasswordForm extends ConsumerStatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  ConsumerState<ResetPasswordForm> createState() =>
      _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  late final ProviderSubscription<BetterAuthState> _authListener;

  @override
  void initState() {
    super.initState();

    _authListener = ref.listenManual<BetterAuthState>(
      betterAuthProvider,
      (previous, next) {
        final errorMessage = next.errorMessage;
        if (errorMessage == null || errorMessage.isEmpty) return;
        if (previous?.errorMessage == errorMessage) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      },
    );
  }

  @override
  void dispose() {
    _authListener.close();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResetPasswordSuccessDialog(email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authResetPasswordFormProvider);
    final formNotifier = ref.read(authResetPasswordFormProvider.notifier);

    return ModernCard(
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recuperar Contraseña',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa tu correo electrónico y te enviaremos instrucciones para restablecer tu contraseña.',
              style: TextStyle(color: Color(0xFF7f8c8d)),
            ),
            const SizedBox(height: 32),

            ModernInputField(
              label: 'Correo Electrónico',
              hint: 'ejemplo@correo.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              onChanged: formNotifier.onEmailChange,
              errorMessage: formState.isFormPosted
                  ? formState.email.errorMessage
                  : null,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Enviar Instrucciones',
                icon: Icons.send,
                isLoading: formState.isPosting,
                onPressed: formState.isPosting
                    ? null
                    : () async {
                        final ok = await formNotifier.onFormSubmit();
                        if (!context.mounted) return;
                        if (ok) {
                          _showSuccessDialog(context, formState.email.value);
                        }
                      },
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Text(
                  'Volver al inicio de sesión',
                  style: TextStyle(
                    color: Color(0xFF3498db),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordSuccessDialog extends StatelessWidget {
  final String email;

  const ResetPasswordSuccessDialog({super.key, required this.email});

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
              Icons.mark_email_read,
              color: Color(0xFF27ae60),
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Email Enviado!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hemos enviado las instrucciones para restablecer tu contraseña a $email',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
          ),
        ],
      ),
      actions: [
        ModernButton(
          text: 'Entendido',
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Volver a login
          },
        ),
      ],
    );
  }
}
