
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/shared/widgets/custom_filled_button.dart';

class HomeAdminBody extends StatelessWidget {
  const HomeAdminBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all( 20 ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
          
                const SizedBox(height: 20,),
                const Text(
                  'Home Admin Page', 
                  style: TextStyle(
                    fontSize: 25, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white70
                  )
                ),
                const SizedBox(height: 30,),
              
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFilledButton(
                      height: 60,
                      width: 270,
                      padding: const EdgeInsets.only(top: 3, bottom: 3,),
                      fontSize: 14,
                      radius: const Radius.circular(40),
                      spreadRadius: 2,
                      blurRadius: 4,
                      text: ' Gest. de Trabajos realizados',
                      textColor: Colors.black54,
                      buttonColor: const Color.fromARGB(255, 20, 140, 238).withValues( alpha: 0.9 ),
                      shadowColor: Colors.black45,
                      onPressed: () => context.push('/our-works'),
                      icon: Icons.workspace_premium_outlined,
                    ),
                    const SizedBox(height: 25,),
                    CustomFilledButton(
                      height: 60,
                      width: 270,
                      padding: const EdgeInsets.only(top: 3, bottom: 3,),
                      fontSize: 14,
                      radius: const Radius.circular(40),
                      spreadRadius: 2,
                      blurRadius: 4,
                      text: ' Gest. de Servicios',
                      textColor: Colors.black54,
                      buttonColor: const Color.fromARGB(255, 20, 140, 238).withValues( alpha: 0.9 ),
                      shadowColor: Colors.black45,
                      onPressed: () => context.push('/services'),
                      icon: Icons.car_repair_outlined,
                    ),
                    const SizedBox(height: 25,),
                    CustomFilledButton(
                      height: 60,
                      width: 270,
                      padding: const EdgeInsets.only(top: 3, bottom: 3,),
                      fontSize: 14,
                      radius: const Radius.circular(40),
                      spreadRadius: 2,
                      blurRadius: 4,
                      text: ' Gest. de Mensajeria',
                      textColor: Colors.black54,
                      buttonColor: const Color.fromARGB(255, 20, 140, 238).withValues( alpha: 0.9 ),
                      shadowColor: Colors.black45,
                      onPressed: () => context.push('/messages'),
                      icon: Icons.message_outlined,
                    ),
                    const SizedBox(height: 25,),
                    CustomFilledButton(
                      height: 60,
                      width: 270,
                      padding: const EdgeInsets.only(top: 3, bottom: 3,),
                      fontSize: 14,
                      radius: const Radius.circular(40),
                      spreadRadius: 2,
                      blurRadius: 4,
                      text: ' Gest. de Reservas',
                      textColor: Colors.black54,
                      buttonColor: const Color.fromARGB(255, 20, 140, 238).withValues( alpha: 0.9 ),
                      shadowColor: Colors.black45,
                      onPressed: () => context.push('/reservas-config'),
                      icon: Icons.message_outlined,
                    ),
                    const SizedBox(height: 20,),
                    CustomFilledButton(
                      height: 60,
                      width: 270,
                      padding: const EdgeInsets.only(top: 3, bottom: 3,),
                      fontSize: 14,
                      radius: const Radius.circular(40),
                      spreadRadius: 2,
                      blurRadius: 4,
                      text: 'Gest. de Productos(Desa...)',
                      textColor: Colors.white60,
                      buttonColor: Colors.black45,
                      shadowColor: Colors.black45,
                      onPressed: () {},
                      icon: Icons.production_quantity_limits_outlined,
                    ),
                    const SizedBox(height: 20,),
      
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


