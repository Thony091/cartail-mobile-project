// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// import '../../../config/config.dart';
import '../../providers/providers.dart';
import '../../shared/shared.dart';
import '../../shared/widgets/custom_product_field.dart';

class LoginPage extends StatelessWidget {

  static const name = 'LoginPage';
  
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return  SafeArea(
      child: Scaffold(
      
        appBar: CustomAppBar(
          title: "Login",
          styleText: const TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                offset: Offset(1.0, 3.0),
                blurRadius: 3.0,
                color: Colors.black54
              )
            ]
          ),
          customIcon: Icons.arrow_back_rounded,
          iconSize: 25,
          iconColor: Colors.black,
          onIconPressed: () => context.go('/'),
        ),

        body:  BackgroundImageWidget(
          startColor: Colors.black87,
          endColor: Colors.white60,
          opacity: 0.1,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const SizedBox( height: 75 ),
                FadeInUp(child: const _LoginForm()),
              ],
            ),
          )
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

    final loginForm = ref.watch(( loginFormProvider ));

    ref.listen(authProvider, (previous, next) { 
      if ( next.errorMessage.isEmpty )  return;
      showSnackBar( context, next.errorMessage );
    });

    final size = MediaQuery.of(context).size;
    // final textStyles = Theme.of(context).textTheme;

    return Stack(
      children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Stack(
            children:[
             Column(
              children: [
                const SizedBox( height: 50 ),
                Container(
                  padding: const EdgeInsets.all(12),
                  // height: size.height * 0.65,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 234, 234, 234),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black54,
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child : Column(
                    children: [
                      const SizedBox( height: 60 ),
                      
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        label: 'Correo',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: ref.read(loginFormProvider.notifier).onEmailChange,
                        errorMessage: loginForm.isFormPosted 
                        ? loginForm.email.errorMessage
                        : null,
                      ),
                      const SizedBox( height: 30 ),
                  
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        label: 'Contraseña',
                        obscureText: true,
                        onChanged: ref.read(loginFormProvider.notifier).onPasswordChanged,
                        errorMessage: loginForm.isFormPosted
                        ? loginForm.password.errorMessage
                        : null,
                      ),
                      const SizedBox(height: 5),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => context.push('/reset-password'), 
                            child: const Text('¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      
                      const SizedBox( height: 10 ),
                  
                      CustomFilledButton(
                        height: 60,
                        width: size.width * 0.7,
                        radius: const Radius.circular(100),
                        shadowColor: const Color.fromARGB(255, 255, 255, 255),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offsetY: 3,
                        icon: Icons.person_2_rounded,
                        iconSeparatorWidth: 50,
                        text: 'Ingresar',
                        fontSize: 22,
                        buttonColor: Colors.blueAccent.shade400,
                        mainAxisAlignment: MainAxisAlignment.start,
                        onPressed: loginForm.isPosting
                          ? null
                          : ref.read(loginFormProvider.notifier).onFormSubmit
                      ),
                      const SizedBox( height: 10 ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes cuenta?',
                            style: TextStyle(fontSize: 15),
                          ),
                          TextButton(
                            onPressed: () => context.push('/register'), 
                            child: const Text('Crea una aquí',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox( height: 10 ),
                    ],
                  )
                ),  
              ],
            ),

            Center(
              heightFactor: .55,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 225, 191, 37),
                    width: 2,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black54,
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/AR_2.png',
                  width: 130, 
                  height: 130, 
                  fit: BoxFit.contain,
                ),
              ),
            ),
            ]
          ),
        ),
      ),
      ]
    );
  }
}