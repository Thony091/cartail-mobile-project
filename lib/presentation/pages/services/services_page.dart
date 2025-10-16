import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../config/config.dart';
import '../../presentation_container.dart';
import 'component/service_card.dart';

class ServicesPage extends ConsumerWidget {

  static const name = 'ServicesPage';
  
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final servicesState = ref.watch(servicesProvider);
    final authState     = ref.watch(authProvider);
    final text          = AppTheme().getTheme().textTheme;
    // final color         = AppTheme().getTheme().colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text( authState.authStatus != AuthStatus.authenticated
          ? "Nuestros Servicios" 
          :( !authState.userData!.isAdmin )
            ? "Nuestros Servicios" 
            : "Servicios disponibles",
          style: text.titleLarge,
        ),
        // backgroundColor: color.primary,
        elevation: 4.0,
        flexibleSpace: AppTheme.headerBgColor,
      ),
      body: BackgroundImageWidget(
        opacity: 0.45,
        child: ( authState.authStatus != AuthStatus.authenticated )
          ? servicesState.services.isEmpty 
           ? FadeInRight(
                child: Center(
                  child: Text(
                    'No hay Servicios en este momento', 
                    style: text.bodyMedium,
                  )
                )
              )
            : const _ServiceBodyPage()
          : ( !authState.userData!.isAdmin )
            ? servicesState.services.isEmpty 
              ? FadeInRight(
                  child: Center(
                    child: Text(
                      'No hay Servicios en este momento', 
                      style: text.bodyMedium,
                    )
                  )
                )
              : const _ServiceBodyPage()
            : servicesState.services.isEmpty 
              ? FadeInRight(
                  child: Center(
                    child: Text(
                      'No hay Servicios en este momento', 
                      style: text.bodyMedium,
                    )
                  )
                )
              : const _ServiceAdminBodyPage()
      ),
      floatingActionButton: ( authState.authStatus != AuthStatus.authenticated)
        ? null 
        : ( authState.userData!.isAdmin ) 
          ? FloatingActionButton.extended(
              label: const Text( 'Crear Servicio' ),
              icon: const Icon( Icons.add ),
              onPressed: () => context.pushReplacement('/service-edit/new'),
            )
          : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      // drawer: SideMenu(scaffoldKey: scaffoldKey),
    );
  }
}

//* Vista de los servicios para el usuario
class _ServiceBodyPage extends ConsumerStatefulWidget {
  const _ServiceBodyPage();

  @override
  _ServiceBodyPageState createState() => _ServiceBodyPageState();
}

class _ServiceBodyPageState extends ConsumerState {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesProvider.notifier).getServices();
    });
  }

  @override
  Widget build(BuildContext context) {

    final servicesState = ref.watch(servicesProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child:  MasonryGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        itemCount: servicesState.services.length,
        itemBuilder: ( context, index) {
          final service = servicesState.services[index];
          return GestureDetector(
            onTap: () => context.push('/service/${service.id}'),
            child: FadeInRight(child: ServiceCard( service: service )),
          );
        },
      ),
    );
  }
}

//* Vista de los servicios para el administrador
class _ServiceAdminBodyPage extends ConsumerStatefulWidget {
  const _ServiceAdminBodyPage();

  @override
  _ServiceAdminBodyPageState createState() => _ServiceAdminBodyPageState();
}

class _ServiceAdminBodyPageState extends ConsumerState {

  @override
  Widget build(BuildContext context) {

    final servicesState = ref.watch(servicesProvider);
    void showDeleteSnackbar( BuildContext context ) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio Eliminado')
        )
      );
    }
    
    return Padding(
      padding: const EdgeInsets.only( left: 20, top: 10),
      child:  ListView.builder(
        itemCount: servicesState.services.length,
        itemBuilder: ( context, index) {
          final service = servicesState.services[index];
          return Column(
            children:
              [
                FadeInRight(
                  child: AdminCardService( 
                    service: service,
                    onTapdEdit: () => context.push('/service-edit/${service.id}'),
                    onTapDelete: () => showDialog(
                      context: context, 
                      builder: (context) {
                        return PopUpPreguntaWidget(
                          pregunta: '¿Estas seguro de eliminar el servicio?',
                          // confirmar: () {},
                          confirmar: () async { 
                            final bool value = await ref.read(servicesProvider.notifier)
                              .deleteService(service.id);
                            if (!context.mounted) return;
                            if ( value ) {
                              showDeleteSnackbar(context);
                              context.pop();
                            }
                          },
                          cancelar: () => context.pop()
                        );
                      }
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ] 
          );
        },        
      ),
    );
  }
}