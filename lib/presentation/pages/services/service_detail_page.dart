import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/config.dart';
import '../../../domain/domain.dart';
import '../../presentation_container.dart';
import '../../shared/widgets/custom_product_field.dart';

class ServiceDetailPage extends ConsumerWidget{

  final String serviceId;
  static const String name = 'ServiceDetailPage';

  const ServiceDetailPage({super.key, required this.serviceId});
    
  void showSnackbar( BuildContext context ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto Actualizado'))
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authState = ref.watch( authProvider );
    final serviceState = ref.watch( serviceProvider( serviceId ) );
    final color = AppTheme().getTheme().colorScheme;
    
    return GestureDetector(
      onTap: () => FocusScope.of( context ).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: serviceState.service?.id != 'new' 
            ? Text( serviceState.service?.name ?? ' Cargando...')
            : const Text( 'Nuevo Servicio'),
          backgroundColor: color.primary,
        ),
        body: serviceState.isLoading
          ? const FullScreenLoader()
          : BackgroundImageWidget(opacity: 0.1, child: _ServiceDetailBodyPage( service: serviceState.service! )),
        floatingActionButton:  ( authState.authStatus != AuthStatus.authenticated)
          ? null 
          : (authState.userData!.isAdmin) 
            ? 
              FloatingActionButton.extended(
                label: const Text('Guardar'),
                icon: const Icon( Icons.save_as_outlined ),
                onPressed: () {
                  if ( serviceState.service == null) return;
                  ref.read(
                    serviceFormProvider( serviceState.service! ).notifier
                  ).onFormSubmit()
                  .then((value) {
                    if ( !value ) return;
                    showSnackbar(context);
                    context.push('/services');
                  });
                },
              )
            : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      )
    );
  }

}

class _ServiceDetailBodyPage extends ConsumerWidget {

  final Services service;

  const _ServiceDetailBodyPage({ required this.service });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return ListView(
      children: [
        const SizedBox( height: 20 ),
        SizedBox(
          height: 250,
          width: 600,
          child: CustomImagesGallery(images: service.images),
        ),

        const SizedBox( height: 20 ),

        Center( 
          child: Text( 
            service.name, 
            style: TextStyle(
              fontSize: 17,
              fontStyle: FontStyle.italic,
              textBaseline: TextBaseline.alphabetic,
              color: Colors.amber.shade100,
              shadows: const [ 
                Shadow(
                  color: Colors.black, 
                  offset: Offset(0, 1), 
                  blurRadius: 1
                )
              ]
              
            ),   
          )
        ),

        const SizedBox( height: 20 ),

        _ServiceInformation(service: service),

      ],
    );
  }
}

class _ServiceInformation extends ConsumerWidget {

  final Services service;
  
  const _ServiceInformation({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref ) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generales' ,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade100,
              shadows: const [ 
                Shadow(
                  color: Colors.black, 
                  offset: Offset(0, 1), 
                  blurRadius: 1
                )
              ]
            ), 
          ),
          const SizedBox(height: 20 ),
          CustomProductField(
            readOnly: true,
            isTopField: true,
            label: 'Nombre',
            textSize: 16,
            textWeight: FontWeight.bold,
            textShadows: const [
              Shadow(
                color: Color.fromARGB(255, 247, 211, 129), 
                offset: Offset(0, 0), 
                blurRadius: 2
              )
            ],
            initialValue: service.name,
          ),
          CustomProductField( 
            readOnly: true,
            // isTopField: true,
            isBottomField: true,
            label: 'Precio',
            textSize: 16,
            textShadows: const [
              Shadow(
                color: Color.fromARGB(255, 247, 211, 129), 
                offset: Offset(0, 0), 
                blurRadius: 2
              )
            ],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: 'Entre ${service.minPrice.toString()} - ${service.maxPrice.toString()}',
          ),

          const SizedBox(height: 15 ),

          CustomProductField( 
            isTopField: true,
            isBottomField: true,
            readOnly: true,
            maxLines: 6,
            label: 'Descripción',
            textSize: 16,
            textShadows: const [
              Shadow(
                color: Color.fromARGB(255, 247, 211, 129), 
                offset: Offset(0, 0), 
                blurRadius: 2
              )
            ],
            keyboardType: TextInputType.multiline,
            initialValue: service.description,
          ),
          const SizedBox(height: 30 ),
        ],
      )
    );
  }
}
