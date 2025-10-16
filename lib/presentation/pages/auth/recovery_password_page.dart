import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../shared/shared.dart';
import '../../shared/widgets/custom_product_field.dart';

class ResetPasswordPage extends StatelessWidget {

  static const name = 'ResetPasswordPage';
  
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Recuperar contraseña",
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
          onIconPressed: () => context.pop(),
        ),
        body: BackgroundImageWidget(
          startColor: Colors.black87,
          endColor: Colors.white60,
          opacity: 0.1,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const SizedBox( height: 75 ),
                FadeInUp(child: const _ForgotPasswordForm()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordForm extends ConsumerWidget {
  const _ForgotPasswordForm();

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final forgotPasswordForm = ref.watch( resetPasswordFormProvider );
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(12),
              height: size.height * 0.5,
              width: size.width,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 234, 234, 234),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  CustomProductField(
                    isBottomField: true,
                    isTopField: true,
                    label: 'Correo',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: ref.read( resetPasswordFormProvider.notifier ).onEmailChange,
                    errorMessage: forgotPasswordForm.isFormPosted 
                      ? forgotPasswordForm.email.errorMessage
                      : null,
                  ),
                  const SizedBox(height: 30),
                  CustomFilledButton(
                    height: 60,
                    width: size.width * 0.7,
                    radius: const Radius.circular(100),
                    shadowColor: const Color.fromARGB(255, 255, 255, 255),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offsetY: 3,
                    icon: Icons.email_rounded,
                    iconSeparatorWidth: 50,
                    text: 'Enviar',
                    fontSize: 22,
                    buttonColor: Colors.blueAccent.shade400,
                    mainAxisAlignment: MainAxisAlignment.start,
                    onPressed: forgotPasswordForm.isPosting
                      ? null
                      : () async {
                        final bool value = await ref.read( resetPasswordFormProvider.notifier ).onFormSubmit();
                        if( !context.mounted ) return;
                        if( value ) {
                          showDialog(
                            context: context,
                            builder: (context) => const PopUpMensajeFinalWidget(text: 'Se ha enviado un mesaje a su correo.'),
                          );
                          await Future.delayed( const Duration( milliseconds: 1500 ) );
                          if ( !context.mounted ) return;
                          context.push('/login');
                        }
                      }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
