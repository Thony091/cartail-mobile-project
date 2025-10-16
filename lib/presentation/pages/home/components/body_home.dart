import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/presentation/pages/home/components/home_admin_body.dart';
import 'package:portafolio_project/presentation/pages/home/components/home_user_body.dart';
import 'package:portafolio_project/presentation/providers/providers.dart';

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final size = MediaQuery.of(context).size;
    const String textColumn1 = '¡Transforma tu Renault Duster en una obra maestra sobre ruedas con nuestro servicio de Detailing exclusivo! En Nuestro taller especializado, ofrecemos una experiencia única de embellecimiento y protección de tu vehículo, centrandonos en cada detalle de tu amada Renault Duster.';
    const String textColumn2 = '¡Experimenta  la potencia y el estilo sin igual de tu MINI john Cooper Works llevados al máximo nivel con nuestra transformación exclusiva! En nuestro talle especializado, nos enorgullese ofrecer un servicio personalizado  que resalta la esencia deportiva y elegancia intrinseca de tu MINI JCW.';
    const String detailingDescription = 'El detailing, en el servicio automotriz, es el conjunto de tecnicas centeradas en la limpieza perfecta del vehiculo sin causar deterioro de los materiales que lo componen. Es más, se encarga de solucionar defectos estéticos y proteger el auto ante la mayoria de las agresiones externas.';
    final authStateProvider = ref.watch( authProvider ).userData;
    final authStatusProvider  = ref.watch( authProvider );

    if ( authStateProvider == null || authStateProvider.isAdmin == false ){
      return  HomeUserBody(
        size: size, 
        textColumn1: textColumn1, 
        textColumn2: textColumn2, 
        detailingDescription: detailingDescription
      );
    }
    else if ( authStatusProvider.authStatus == AuthStatus.authenticated && authStateProvider.isAdmin == true ) {
      return  const HomeAdminBody();
    }
    else {
      return  HomeUserBody(
        size: size, 
        textColumn1: textColumn1, 
        textColumn2: textColumn2, 
        detailingDescription: detailingDescription
      );
    }
  }
}
