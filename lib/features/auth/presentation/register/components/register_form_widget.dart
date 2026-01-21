import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/presentation_container.dart';

class RegisterFormWidget extends ConsumerWidget {
  const RegisterFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(( registerFormProvider ));

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
                          onChanged: ref.read( registerFormProvider.notifier ).onNameChange,
                          errorMessage: registerForm.isFormPosted
                            ? registerForm.name.errorMessage
                            : null,
                        ),
                        const SizedBox(height: 20),
                        ModernInputField(
                          label: 'RUT (*)',
                          hint: 'Ej: 12345678-9',
                          prefixIcon: const Icon(Icons.badge),
                          onChanged: ref.read( registerFormProvider.notifier ).onRutChange,
                          errorMessage: registerForm.isFormPosted
                            ? registerForm.rut.errorMessage
                            : null,
                        ),
                        const SizedBox(height: 20),
                        ModernInputField(
                          label: 'Fecha de Nacimiento',
                          hint: registerForm.birthday.value.isEmpty 
                            ? 'DD/MM/AAAA' 
                            : registerForm.birthday.value,
                          prefixIcon: const Icon(Icons.calendar_today),
                          readOnly: true,
                          onTap: () => _selectBirthday(context, ref),
                          onChanged: ref.read( registerFormProvider.notifier ).onBirthayChange,
                          errorMessage: registerForm.isFormPosted
                            ? registerForm.birthday.errorMessage
                            : null,
                        ),
                        const SizedBox(height: 20),
                        ModernInputField(
                          label: 'Correo Electrónico (*)',
                          hint: 'ejemplo@correo.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email),
                          onChanged: ref.read( registerFormProvider.notifier ).onEmailChange,
                          errorMessage: registerForm.isFormPosted
                            ? registerForm.email.errorMessage
                            : null,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        ModernInputField(
                          label: 'Número de Teléfono (*)',
                          hint: 'Ej: 987654321',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone),
                          onChanged: ref.read( registerFormProvider.notifier ).onPhoneChange,
                          errorMessage: registerForm.isFormPosted
                            ? registerForm.phone.errorMessage
                            : null,
                        ),
                        const SizedBox(height: 20),
                        ModernInputField(
                          label: 'Contraseña (*)',
                          hint: 'Mínimo 6 caracteres',
                          obscureText: registerForm.isObscurePassword,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              registerForm.isObscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => ref.read( registerFormProvider.notifier ).onObscurePasswordChanged(!registerForm.isObscurePassword),
                          ),
                          onChanged: ref.read( registerFormProvider.notifier ).onPasswordChanged,
                          errorMessage: registerForm.isFormPosted
                            ? registerForm.password.errorMessage
                            : null,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ModernButton(
                            text: 'Crear Cuenta',
                            icon: Icons.person_add,
                            onPressed: registerForm.isPosting
                              ? null
                              : () async {
                                final bool value = await ref.read( registerFormProvider.notifier ).onFormSubmit();
                                if ( !context.mounted ) return;
                                if ( registerForm.isValid && value == true ) {
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
      ref.read( registerFormProvider.notifier ).onBirthayChange( birthday );
    }
  }
}