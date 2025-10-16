import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/config.dart';
import '../../presentation_container.dart';
import '../../shared/widgets/custom_product_field.dart';

class RegisterPage extends StatelessWidget {

  static const name = 'RegisterPage';
  
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {

    final color = AppTheme().getTheme().colorScheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear cuenta'),
          backgroundColor: color.primary,
        ),
        body: BackgroundImageWidget(
          opacity: 0.1,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const SizedBox( height: 15 ),
                FadeInDown(
                  child: const CustomTextWithEffect(
                    text: "Ingresar Datos", 
                    textStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
                FadeInUp(
                  child: const _RegisterForm(),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}

class _RegisterForm extends ConsumerWidget {
  const _RegisterForm();

  void showSnackBar( BuildContext context, String message ){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final registerForm = ref.watch(( registerFormProvider ));
    // final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    ref.listen(authProvider, (previous, next) { 
      if ( next.errorMessage.isEmpty )  return;
      showSnackBar( context, next.errorMessage );
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox( height: 20 ),
                Container(
                  padding: const EdgeInsets.all(12),
                  // height: size.height * 0.95,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues( alpha: 0.8 ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues( alpha: 0.5 ),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox( height: 20 ),
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        label: 'Nombre(*) ',
                        keyboardType: TextInputType.name,
                        onChanged: ref.read( registerFormProvider.notifier ).onNameChange,
                        errorMessage: registerForm.isFormPosted
                          ? registerForm.name.errorMessage
                          : null,
                      ),
                      const SizedBox( height: 20 ),
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        label: 'Rut(*)',
                        keyboardType: TextInputType.text,
                        onChanged: ref.read( registerFormProvider.notifier ).onRutChange,
                        errorMessage: registerForm.isFormPosted
                          ? registerForm.rut.errorMessage
                          : null,
                      ),
                      const SizedBox( height: 20 ),
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        label: 'Fecha de Nacimiento',
                        keyboardType: TextInputType.text,
                        onChanged: ref.read( registerFormProvider.notifier ).onBirthayChange,
                        errorMessage: registerForm.isFormPosted
                          ? registerForm.birthday.errorMessage
                          : null,
                      ),
                      const SizedBox( height: 20 ),
                  
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        label: 'Correo(*)',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: ref.read( registerFormProvider.notifier ).onEmailChange,
                        errorMessage: registerForm.isFormPosted
                          ? registerForm.email.errorMessage
                          : null,
                      ),
                      const SizedBox( height: 20 ),
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        label: 'Numero de Telefono(*)',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: ref.read( registerFormProvider.notifier ).onPhoneChange,
                        errorMessage: registerForm.isFormPosted
                          ? registerForm.phone.errorMessage
                          : null,
                      ),
                      const SizedBox( height: 20 ),
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        label: 'Contraseña(*)',
                        obscureText: true,
                        onChanged: ref.read( registerFormProvider.notifier ).onPasswordChanged,
                        errorMessage: registerForm.isFormPosted
                          ? registerForm.password.errorMessage
                          : null,
                      ),
                      const SizedBox( height: 25 ),
                      CustomFilledButton(
                        height: 60,
                        width: size.width * 0.70,
                        radius: const Radius.circular(25),
                        shadowColor: Colors.white,
                        spreadRadius: 4,
                        blurRadius: 3,
                        icon: Icons.person_add,
                        text: 'Crear',
                        iconSeparatorWidth: 65,
                        fontSize: 22,
                        buttonColor: Colors.blueAccent.shade400,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿Ya tienes cuenta?'),
                          TextButton(
                            onPressed: (){
                              context.push('/login');
                            }, 
                            child: const Text(
                              'Ingresa aquí',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox( height:  15 ),
              ],
            ),
          ]
        ),
      ),
    );
  }
}