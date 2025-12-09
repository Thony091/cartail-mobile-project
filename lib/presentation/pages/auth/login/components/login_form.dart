
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/providers/auth_provider.dart';
import 'package:portafolio_project/presentation/providers/forms/login_form_provider.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_button.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_input_field.dart';

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  void showSnackBar( BuildContext context, String message ){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final loginFormNotifier = ref.read( loginFormProvider.notifier );
    final loginForm         = ref.watch( loginFormProvider );

    ref.listen(authProvider, (previous, next) { 
      if ( next.errorMessage.isEmpty )  return;
      showSnackBar( context, next.errorMessage );
    });

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Iniciar Sesión',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),

          const SizedBox(height: 20),
          
          ModernInputField(
            label: 'Correo Electrónico',
            hint: 'ejemplo@correo.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            onChanged: ref.read(loginFormProvider.notifier).onEmailChange,
            errorMessage: loginForm.isFormPosted
              ? loginForm.email.errorMessage
              : null,
          ),
          
          const SizedBox(height: 20),
          
          ModernInputField(
            label: 'Contraseña',
            hint: '••••••••',
            obscureText: loginForm.isObscurePassword,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                !loginForm.isObscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              ),
              onPressed: () => loginFormNotifier.changeObscurePassword(!loginForm.isObscurePassword),
            ),
            onChanged: loginFormNotifier.onPasswordChanged,
            errorMessage: loginForm.isFormPosted
              ? loginForm.password.errorMessage
              : null,
          ),
          
          const SizedBox(height: 16),
          
          // Enlace "Olvidaste tu contraseña"
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/reset-password'),
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botón de login
          SizedBox(
            width: double.infinity,
            child: ModernButton(
              text: 'Ingresar',
              icon: Icons.login,
              isLoading: loginForm.isPosting,
              onPressed: loginForm.isPosting 
                ? null 
                : loginFormNotifier.onFormSubmit,
            ),
          ),
          
          const SizedBox(height: 18),
          
          // Divider con "O"
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFe2e8f0),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'O',
                  style: TextStyle(
                    color: Color(0xFF7f8c8d),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFe2e8f0),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 18),
          
          // Botón de registro
          SizedBox(
            width: double.infinity,
            child: ModernButton(
              text: 'Crear cuenta nueva',
              icon: Icons.person_add,
              style: ModernButtonStyle.secondary,
              onPressed: () {
                context.push('/register');
                // Navegar a registro
              },
            ),
          ),
        ],
      ),
    );
  }
}