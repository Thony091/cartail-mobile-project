
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart';

import '../../presentation_container.dart';
import 'components/custom_profile_field.dart';

class EditUserProfilePage extends StatelessWidget {

  static const name = 'EditUserProfilePage';

  const EditUserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,
        title: const Text('Edición de Datos'),
      ),
      body: const BackgroundImageWidget(
        opacity: 0.1,
        child: _EditProfileBodyPage()
      ),
    );
  }
}

class _EditProfileBodyPage extends ConsumerWidget {
  const _EditProfileBodyPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final textStyles = Theme.of(context).textTheme;
    final authState = ref.watch( authProvider ).userData!;
    final upForm = ref.watch( updateFormProvider );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox( height: 30 ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ingresar Datos',
                  style: 
                    textStyles.titleLarge,
                ),
              ],
            ),
            const SizedBox( height: 20 ),

            CustomProfileField( 
              readOnly: true,
              isTopField: true,
              isBottomField: true,
              label: 'Correo Electronico',
              initialValue: authState.email,
            ),
            const SizedBox( height: 20 ),
        
            CustomProfileField( 
              readOnly: true,
              obscureText: true,
              isTopField: true,
              isBottomField: true,
              label: 'Contraseña',
              initialValue: authState.password,
            ),
            const SizedBox( height: 20 ),
        
            CustomProfileField( 
              initialValue: authState.nombre,
              isTopField: true,
              isBottomField: true,
              label: 'Nombre',
              onChanged: ref.read( updateFormProvider.notifier ).onNameChange,
              // keyboardType: const TextInputType.numberWithOptions(decimal: true),
              // initialValue: authState.nombre,
              errorMessage: upForm.isFormPosted
                ? upForm.name.errorMessage
                : null,
            ),
            const SizedBox( height: 20 ),

            CustomProfileField(
              initialValue: authState.rut.isEmpty ? '' : authState.rut,
              isTopField: true,
              isBottomField: true,
              label: 'Rut',
              onChanged: ref.read( updateFormProvider.notifier ).onRutChange,
            ),
            const SizedBox( height: 20 ),

            CustomProfileField(
              hint: authState.fechaNacimiento.isEmpty ? 'Escribir Fecha de Nacimiento' : authState.fechaNacimiento, 
              isTopField: true,
              isBottomField: true,
              label: 'Fecha de Nacimiento',
              onChanged: ref.read( updateFormProvider.notifier ).onBirthayChange,
            ),
            const SizedBox( height: 20 ),
        
            CustomProfileField( 
              initialValue: authState.telefono.isEmpty ? '' : authState.telefono,
              isTopField: true,
              isBottomField: true,
              label: 'Numero de Telefono',
              onChanged: ref.read( updateFormProvider.notifier ).onPhoneChange,
              // keyboardType: const TextInputType.numberWithOptions(decimal: true),
              // initialValue: authState.nombre,
              errorMessage: upForm.isFormPosted
                ? upForm.phone.errorMessage
                : null,
            ),
            const SizedBox( height: 20 ),

            CustomProfileField(
              hint: authState.bio.isEmpty ? 'Escribir biografia' : authState.bio,
              maxLines: 4,
              isTopField: true,
              isBottomField: true,
              label: 'Biografia',
              onChanged: ref.read( updateFormProvider.notifier ).onBioChange,
              // keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),

            const SizedBox( height: 30 ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: CustomFilledButton(
                radius: const Radius.circular(20),
                icon: Icons.save,
                text: '     Editar',
                buttonColor: Colors.blueAccent.shade400,
                onPressed: (){ 
                  upForm.isPosting
                  ? null
                  : ref.read( updateFormProvider.notifier )
                    .onUpdateFormSubmit()
                    .then((value) {
                      if( value == true ) {
                        context.push('/profile-user');
                        showDialog(
                          context: context, 
                          builder: (context) => const PopUpMensajeFinalWidget(text: 'El Perfil se ha Actualizado Exitosamente!'),
                        );
                      }
                      else {
                        showDialog(
                          context: context, 
                          builder: (context) => const PopUpMensajeFinalWidget(text: 'El Perfil no se ha Actualizado. Intente de Nuevo!'),
                        );
                      }
                    }
                  );
                }, 
              )
            ),
            const SizedBox( height: 20)
          ],
        ),
      ),
    );
  }
}