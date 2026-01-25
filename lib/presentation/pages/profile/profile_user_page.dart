
// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../../config/config.dart';
import '../../presentation_container.dart';
import 'components/custom_profile_field.dart';

class ProfileUserPage extends StatelessWidget {

  static const name = 'ProfileUserPage';

  const ProfileUserPage({super.key});

  @override
  Widget build(BuildContext context) {

    final scaffoldKey = GlobalKey<ScaffoldState>();
    final color = AppTheme().getTheme().colorScheme;
 
    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        backgroundColor: color.primary,
        title: const Text('Mi Perfil'),
      ),
      body:  const BackgroundImageWidget(
        opacity: 0.1,
        child: _ConfigUserBodyPage()
      ),
    );
  }
}

class _ConfigUserBodyPage extends ConsumerWidget {
  const _ConfigUserBodyPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final authState = ref.watch(betterAuthProvider).session?.user;
    final color = AppTheme().getTheme().colorScheme;
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric( horizontal: 20 ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15,),
            const Text(
              "Cuenta de Usuario",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 25,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.primary.withOpacity(0.9),
                    spreadRadius: 2,
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const SizedBox(
                height: 120,
                width: 120,
                child: const CircleAvatar(foregroundColor: Colors.white,
                  backgroundImage: AssetImage( "assets/avatar.png", )
                )
              ),
            ),
            
            const SizedBox(height: 25,),
            CustomProfileField( 
              readOnly: true,
              isTopField: true,
              label: 'Nombre',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              initialValue: authState?.name ?? 'No Name',
            ),
            CustomProfileField( 
              readOnly: true,
              label: 'Email',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              initialValue: authState?.email ?? 'No Email',
            ),
            CustomProfileField( 
              readOnly: true,
              isBottomField: !authState!.isAdmin 
                ? true 
                : false,
              label: 'Telefono',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              initialValue: authState.phone ?? 'No Phone',
            ),
            if(authState.isAdmin)
              const CustomProfileField( 
                readOnly: true,
                isBottomField: true,
                label: 'Rol',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                initialValue: 'Administrador',
              ),
            const SizedBox(height: 25,),
            CustomProfileField( 
              readOnly: true,
              maxLines: 5,
              isBottomField: true,
              label: 'Biografia',
              keyboardType: TextInputType.multiline,
              initialValue: authState.bio ?? 'No hay biografia',
            ),
            
            const SizedBox(height: 30,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                SizedBox(
                  width: size.width * 0.5,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/edit-user-profile');
                    },
                    child: const Text('Editar'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}