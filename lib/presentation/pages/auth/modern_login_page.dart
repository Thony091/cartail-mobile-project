
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/providers/providers.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_button.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_card.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_input_field.dart';

// import 'modern_reset_password_page.dart';

class ModernLoginPage extends StatelessWidget {
  static const name = 'ModernLoginPage';
  
  const ModernLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo y título
                FadeInDown(
                  child: Column(
                    children: [
                      Container(
                        // alignment: Alignment.center,
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset(
                          'assets/logo/logo-prime-no-bg.png',
                          width: 190, 
                          height: 190, 
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Text(
                        'Tu centro automotriz de confianza',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Formulario de login
                FadeInUp(
                  child: const ModernCard(
                    child: _LoginForm(),
                    // child: Form(
                    //   key: _formKey,
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text(
                    //         'Iniciar Sesión',
                    //         style: TextStyle(
                    //           fontSize: 24,
                    //           fontWeight: FontWeight.w700,
                    //           color: Color(0xFF2c3e50),
                    //         ),
                    //       ),
                    //       const SizedBox(height: 8),
                    //       const Text(
                    //         'Ingresa tus credenciales para continuar',
                    //         style: TextStyle(
                    //           color: Color(0xFF7f8c8d),
                    //         ),
                    //       ),
                    //       const SizedBox(height: 32),
                          
                    //       ModernInputField(
                    //         label: 'Correo Electrónico',
                    //         hint: 'ejemplo@correo.com',
                    //         keyboardType: TextInputType.emailAddress,
                    //         prefixIcon: const Icon(Icons.email_outlined),
                    //         validator: (value) {
                    //           if (value?.isEmpty ?? true) {
                    //             return 'Por favor ingresa tu correo';
                    //           }
                    //           return null;
                    //         },
                    //       ),
                          
                    //       const SizedBox(height: 20),
                          
                    //       ModernInputField(
                    //         label: 'Contraseña',
                    //         hint: '••••••••',
                    //         obscureText: _obscurePassword,
                    //         prefixIcon: const Icon(Icons.lock_outlined),
                    //         suffixIcon: IconButton(
                    //           icon: Icon(
                    //             _obscurePassword
                    //                 ? Icons.visibility_outlined
                    //                 : Icons.visibility_off_outlined,
                    //           ),
                    //           onPressed: () {
                    //             setState(() {
                    //               _obscurePassword = !_obscurePassword;
                    //             });
                    //           },
                    //         ),
                    //         validator: (value) {
                    //           if (value?.isEmpty ?? true) {
                    //             return 'Por favor ingresa tu contraseña';
                    //           }
                    //           return null;
                    //         },
                    //       ),
                          
                    //       const SizedBox(height: 16),
                          
                    //       // Enlace "Olvidaste tu contraseña"
                    //       Align(
                    //         alignment: Alignment.centerRight,
                    //         child: TextButton(
                    //           onPressed: () {
                    //             Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernResetPasswordPage()));
                    //           },
                    //           child: const Text('¿Olvidaste tu contraseña?'),
                    //         ),
                    //       ),
                          
                    //       const SizedBox(height: 24),
                          
                    //       // Botón de login
                    //       SizedBox(
                    //         width: double.infinity,
                    //         child: ModernButton(
                    //           text: 'Ingresar',
                    //           icon: Icons.login,
                    //           isLoading: _isLoading,
                    //           onPressed: _isLoading ? null : _handleLogin,
                    //         ),
                    //       ),
                          
                    //       const SizedBox(height: 24),
                          
                    //       // Divider con "O"
                    //       Row(
                    //         children: [
                    //           Expanded(
                    //             child: Container(
                    //               height: 1,
                    //               color: const Color(0xFFe2e8f0),
                    //             ),
                    //           ),
                    //           const Padding(
                    //             padding: EdgeInsets.symmetric(horizontal: 16),
                    //             child: Text(
                    //               'O',
                    //               style: TextStyle(
                    //                 color: Color(0xFF7f8c8d),
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ),
                    //           Expanded(
                    //             child: Container(
                    //               height: 1,
                    //               color: const Color(0xFFe2e8f0),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                          
                    //       const SizedBox(height: 24),
                          
                    //       // Botón de registro
                    //       SizedBox(
                    //         width: double.infinity,
                    //         child: ModernButton(
                    //           text: 'Crear cuenta nueva',
                    //           icon: Icons.person_add,
                    //           style: ModernButtonStyle.secondary,
                    //           onPressed: () {
                    //             context.push('/register');
                    //             // Navegar a registro
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
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

class _LoginForm extends ConsumerWidget {
  const _LoginForm();

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

    // final size = MediaQuery.of(context).size;
    // final textStyles = Theme.of(context).textTheme;

    return Form(
      // key: _formKey,
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
          // const SizedBox(height: 8),
          // const Text(
          //   'Ingresa tus credenciales para continuar',
          //   style: TextStyle(
          //     color: Color(0xFF7f8c8d),
          //   ),
          // ),
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
            // validator: (value) {
            //   if (value?.isEmpty ?? true) {
            //     return 'Por favor ingresa tu correo';
            //   }
            //   return null;
            // },
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
            // validator: (value) {
            //   if (value?.isEmpty ?? true) {
            //     return 'Por favor ingresa tu contraseña';
            //   }
            //   return null;
            // },
          ),
          
          const SizedBox(height: 16),
          
          // Enlace "Olvidaste tu contraseña"
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/reset-password'),
              // onPressed: () {
              //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernResetPasswordPage()));
              // },
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