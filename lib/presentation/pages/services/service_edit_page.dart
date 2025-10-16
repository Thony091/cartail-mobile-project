import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/config.dart';
import '../../../domain/domain.dart';
import '../../presentation_container.dart';
import '../../shared/widgets/custom_product_field.dart';

class ServiceEditPage extends ConsumerWidget{

  final String serviceId;
  static const String name = 'ServiceEditPage';

  const ServiceEditPage({super.key, required this.serviceId});

  void showSnackbar( BuildContext context ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: serviceId == 'new'
        ? const Text('Servicio Creado')
        : const Text('servicio Actualizado')
      )
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final serviceState = ref.watch( serviceProvider( serviceId ) );
    final color = AppTheme().getTheme().colorScheme;
    
    return GestureDetector(
      onTap: () => FocusScope.of( context ).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(  serviceState.service?.id == 'new'
              ? 'Nuevo servicio'
              : serviceState.service?.name ?? ' Cargando...'
          ),
          backgroundColor: color.primary,
          actions: [
            IconButton(onPressed: () async {
              final photoPath = await CameraGalleryServiceImpl().selectPhoto();
              if ( photoPath == null ) return;

              ref.read( serviceFormProvider(serviceState.service!).notifier )
                .updateServiceImage(photoPath);
    
            }, 
              icon: const Icon( Icons.photo_library_outlined )
            ),

            IconButton(onPressed: () async{
              final photoPath = await CameraGalleryServiceImpl().takePhoto();
              if ( photoPath == null ) return;

              ref.read( serviceFormProvider( serviceState.service!).notifier )
                .updateServiceImage(photoPath);
            }, 
            icon: const Icon( Icons.camera_alt_outlined ))
          ],
        ),
        body: serviceState.isLoading
          ? const FullScreenLoader()
          : BackgroundImageWidget(
              opacity: 0.1, 
              child: _ServiceDetailBodyPage( 
                service: serviceState.service! 
              )
            ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text( 'Guardar' ),
          icon: const Icon( Icons.save_outlined, ),
          onPressed: () {
            if ( serviceState.service == null) return;
            ref.read(
              serviceFormProvider( serviceState.service! ).notifier
            ).onFormSubmit()
            .then((value) {
              if ( !value ) return;
              showSnackbar(context);
              // context.pop();
              context.pushReplacement('/');
            });
          },
        )
      )
    );
  }
}

class _ServiceDetailBodyPage extends ConsumerWidget {

  final Services service;

  const _ServiceDetailBodyPage({ required this.service });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final serviceForm = ref.watch( serviceFormProvider( service ) );

    return ListView(
      children: [
        
        const SizedBox( height: 20 ),

        SizedBox(
          height: 250,
          width: 600,
          child: CustomImagesGallery(images: serviceForm.images),
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

    final serviceForm = ref.watch( serviceFormProvider( service ) );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: service.id != 'new'
            ? Column(
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
                  const SizedBox(height: 15 ),
                  CustomProductField(
                    color: const Color.fromARGB(255, 246, 244, 244),
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
                    initialValue: serviceForm.name.value,
                    onChanged: ref.read( serviceFormProvider( service ).notifier ).onNameChange,
                    errorMessage: serviceForm.name.errorMessage,
                  ),
                  CustomProductField(
                    color: const Color.fromARGB(255, 246, 244, 244),
                    label: 'Precio Minimo',
                    textSize: 16,
                    textShadows: const [
                      Shadow(
                        color: Color.fromARGB(255, 247, 211, 129), 
                        offset: Offset(0, 0), 
                        blurRadius: 2
                      )
                    ],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    // initialValue: serviceForm.minPrice.value.toString(),
                    hint: serviceForm.minPrice.value.toString(),
                    onChanged: (value) => ref.read( serviceFormProvider( service ).notifier )
                      .onMinPriceChange( int.parse(value) ),
                    errorMessage: serviceForm.minPrice.errorMessage,
                  ),
                  CustomProductField( 
                    color: const Color.fromARGB(255, 246, 244, 244),
                    isBottomField: true,
                    label: 'Precio Maximo',
                    textSize: 16,
                    textShadows: const [
                      Shadow(
                        color: Color.fromARGB(255, 247, 211, 129), 
                        offset: Offset(0, 0), 
                        blurRadius: 2
                      )
                    ],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    // initialValue: serviceForm.maxPrice.value.toString(),
                    hint: serviceForm.maxPrice.value.toString(),
                    onChanged: (value) => ref.read( serviceFormProvider( service ).notifier )
                      .onMaxPriceChange( int.parse(value) ),
                    errorMessage: serviceForm.minPrice.errorMessage,
                  ),
              
                  const SizedBox(height: 15 ),
              
                  CustomProductField(
                    isTopField: true,
                    isBottomField: true,
                    color: const Color.fromARGB(255, 246, 244, 244),
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
                    initialValue: serviceForm.description.value,
                    onChanged: ref.read( serviceFormProvider( service ).notifier ).onDescriptionChange,
                    errorMessage: serviceForm.description.errorMessage,
                  ),
              
                  const SizedBox(height: 30 ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Generales'),
                  const SizedBox(height: 20 ),
                  CustomProductField(
                    isTopField: true,
                    label: 'Nombre',
                    textSize: 16,
                    textShadows: const [
                      Shadow(
                        color: Color.fromARGB(255, 247, 211, 129), 
                        offset: Offset(0, 0), 
                        blurRadius: 2
                      )
                    ],
                    initialValue: serviceForm.name.value,
                    onChanged: ref.read( serviceFormProvider( service ).notifier ).onNameChange,
                  ),

                  CustomProductField( 
                    label: 'Precio Minimo',
                    textSize: 16,
                    textShadows: const [
                      Shadow(
                        color: Color.fromARGB(255, 247, 211, 129), 
                        offset: Offset(0, 0), 
                        blurRadius: 2
                      )
                    ],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    initialValue: serviceForm.minPrice.value.toString(),
                    onChanged: (value) => ref.read( serviceFormProvider( service ).notifier )
                      .onMinPriceChange( int.parse(value)),
                    errorMessage: serviceForm.minPrice.errorMessage,
                  ),
                  CustomProductField( 
                    isBottomField: true,
                    label: 'Precio Maximo',
                    textSize: 16,
                    textShadows: const [
                      Shadow(
                        color: Color.fromARGB(255, 247, 211, 129),
                        offset: Offset(0, 0),
                        blurRadius: 2
                      )
                    ],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    initialValue: serviceForm.maxPrice.value.toString(),
                    onChanged: (value) => ref.read( serviceFormProvider( service ).notifier )
                      .onMaxPriceChange( int.parse(value) ),
                    errorMessage: serviceForm.minPrice.errorMessage,
                  ),
                  const SizedBox(height: 15 ),
                  
                  CustomProductField(
                    isTopField: true,
                    isBottomField: true,
                    color: const Color.fromARGB(255, 223, 222, 222),
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
                    initialValue: serviceForm.description.value,
                    onChanged: ref.read( serviceFormProvider( service ).notifier ).onDescriptionChange,
                    hint: 'Descripción del servicio',
                  ),

                  const SizedBox(height: 30 ),
                ],
              ),
        ),
      ),
    );
  }
}
