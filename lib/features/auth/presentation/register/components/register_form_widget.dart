import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/auth/presentation/providers/forms/register_form_provider.dart';
import 'package:portafolio_project/presentation/presentation_container.dart';

class RegisterFormWidget extends ConsumerStatefulWidget {
  const RegisterFormWidget({super.key});

  @override
  ConsumerState<RegisterFormWidget> createState() =>
      _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends ConsumerState<RegisterFormWidget> {
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

  @override
  Widget build(BuildContext context) {
    final registerFormState = ref.watch(authRegisterFormProvider);
    final registerFormNotifier = ref.read(authRegisterFormProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea).withValues(alpha: .1),
            const Color(0xFFf8fafc),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Título
              FadeInDown(
                child: const Text(
                  'Únete a DriveTail',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea tu cuenta para acceder a todos nuestros servicios',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7f8c8d),
                ),
              ),
              const SizedBox(height: 40),
              // Formulario
              FadeInUp(
                child: ModernCard(
                  child: Form(
                    // key: _formKey,
                    child: Column(
                      children: [
                        ModernInputField(
                          label: 'Nombre Completo (*)',
                          hint: 'Ej: Juan Pérez',
                          prefixIcon: const Icon(Icons.person),
                          onChanged: registerFormNotifier.onNameChange,
                          errorMessage: registerFormState.isFormPosted
                            ? registerFormState.name.errorMessage
                            : null,
                        ),
                        const SizedBox(height: 20),
                        ModernInputField(
                          label: 'RUT (*)',
                          hint: 'Ej: 12345678-9',
                          prefixIcon: const Icon(Icons.badge),
                          onChanged: registerFormNotifier.onRutChange,
                          errorMessage: registerFormState.isFormPosted
                            ? registerFormState.rut.errorMessage
                            : null,
                        ),
                        const SizedBox(height: 20),
                        ModernInputField(
                          label: 'Fecha de Nacimiento',
                          hint: registerFormState.birthday.value.isEmpty 
                            ? 'DD/MM/AAAA' 
                            : registerFormState.birthday.value,
                          prefixIcon: const Icon(Icons.calendar_today),
                          readOnly: true,
                          onTap: () => _selectBirthday(context, ref),
                          onChanged: registerFormNotifier.onBirthayChange,
                          errorMessage: registerFormState.isFormPosted
                            ? registerFormState.birthday.errorMessage
                            : null,
                        ),
                        const SizedBox(height: 20),
                        ModernInputField(
                          label: 'Correo Electrónico (*)',
                          hint: 'ejemplo@correo.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email),
                          onChanged: registerFormNotifier.onEmailChange,
                          errorMessage: registerFormState.isFormPosted
                            ? registerFormState.email.errorMessage
                            : null,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        ModernInputField(
                          label: 'Número de Teléfono (*)',
                          hint: 'Ej: 987654321',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone),
                          onChanged: registerFormNotifier.onPhoneChange,
                          errorMessage: registerFormState.isFormPosted
                            ? registerFormState.phone.errorMessage
                            : null,
                        ),
                        const SizedBox(height: 20),
                        ModernInputField(
                          label: 'Contraseña (*)',
                          hint: 'Mínimo 6 caracteres',
                          obscureText: registerFormState.isObscurePassword,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              registerFormState.isObscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => registerFormNotifier.onObscurePasswordChanged(!registerFormState.isObscurePassword),
                          ),
                          onChanged: registerFormNotifier.onPasswordChanged,
                          errorMessage: registerFormState.isFormPosted
                            ? registerFormState.password.errorMessage
                            : null,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ModernButton(
                            text: 'Crear Cuenta',
                            icon: Icons.person_add,
                            onPressed: registerFormState.isPosting
                              ? null
                              : () async {
                                final bool value = await registerFormNotifier.onFormSubmit();
                                if ( !context.mounted ) return;
                                if ( registerFormState.isValid && value == true ) {
                                  showDialog(
                                    context: context, 
                                    builder: (context) => const PopUpMensajeFinalWidget( text: 'Se ha Registrado Exitosamente!' ),
                                  );
                                  await Future.delayed( const Duration( milliseconds: 1500 ) );
                                  if ( !context.mounted ) return;
                                  context.push('/login');
                                }
                              } 
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '¿Ya tienes cuenta? ',
                              style: TextStyle(color: Color(0xFF7f8c8d)),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/login'),
                              child: const Text(
                                'Inicia sesión',
                                style: TextStyle(
                                  color: Color(0xFF3498db),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _selectBirthday(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 años atrás
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      final birthday = '${picked.day.toString().padLeft(2, '0')}/'
        '${picked.month.toString().padLeft(2, '0')}/'
        '${picked.year}';
      ref.read(authRegisterFormProvider.notifier).onBirthayChange(birthday);
    }
  }
}
