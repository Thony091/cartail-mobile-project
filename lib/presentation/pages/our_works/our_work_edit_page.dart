import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/config.dart';
import '../../../domain/domain.dart';
import '../../presentation_container.dart';
import '../../providers/forms/work_form_provider.dart';
import '../../shared/widgets/custom_product_field.dart';

class OurWorkEditPage extends ConsumerWidget{

  final String workId;
  static const String name = 'OurWorkEditPage';

  const OurWorkEditPage({super.key, required this.workId});

  void showSnackbar( BuildContext context ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: workId == 'new'
        ? const Text('Trabajo Creado')
        : const Text('Trabajo Actualizado')
      )
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final workState = ref.watch( workProvider( workId ) );
    if (workState.work == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final workForm = ref.watch( workFormProvider( workState.work! ) );
    final color = AppTheme().getTheme().colorScheme;

    void showErrorSnackbar( BuildContext context ) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: workForm.image.value.isEmpty 
          ? Text('${workForm.image.errorMessage}')
          : const Text('')
        )
      );
    }
    
    return GestureDetector(
      onTap: () => FocusScope.of( context ).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text( workState.work?.name ?? ' Cargando...'),
          backgroundColor: color.primary,
          actions: [
            IconButton(onPressed: () async {
              final photoPath = await CameraGalleryServiceImpl().selectPhoto();
              if ( photoPath == null ) return;
              
              ref.read( workFormProvider(workState.work!).notifier )
                .updateWorkImage(photoPath);
    
            }, 
            icon: const Icon( Icons.photo_library_outlined )),

            IconButton(onPressed: () async{
              final photoPath = await CameraGalleryServiceImpl().takePhoto();
              if ( photoPath == null ) return;

              ref.read( workFormProvider( workState.work!).notifier )
                .updateWorkImage(photoPath);
            }, 
            icon: const Icon( Icons.camera_alt_outlined ))
          ],
        ),
        body: workState.isLoading
          ? const FullScreenLoader()
          : BackgroundImageWidget(
              opacity: 0.1,
              image: workState.work?.image, 
              child: _WorkDetailBodyPage(
                work: workState.work! 
              )
            ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text( 'Guardar' ),
          icon: const Icon( Icons.save_outlined, ),
          onPressed: () {
            if ( workState.work == null) return;
            ref.read(
              workFormProvider( workState.work! ).notifier
            ).onFormSubmit()
            .then((value) {
              if ( !value ) return showErrorSnackbar(context);
              showSnackbar(context);
              context.pop();
            });
          },
        )
      )
    );
  }
}

class _WorkDetailBodyPage extends ConsumerWidget {

  final Works work;

  const _WorkDetailBodyPage({ required this.work });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final workForm = ref.watch( workFormProvider( work ) );

    return ListView(
      children: [
        const SizedBox( height: 15 ),

        SizedBox(
          height: 250,
          width: 550,
          child: CustomImageGallery(image: workForm.image.value),
        ),

        const SizedBox( height: 20 ),

        Center( 
          child: Text( 
            workForm.name.value, 
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

        _WorkInformation(work: work),

      ],
    );
  }
}


class _WorkInformation extends ConsumerWidget {

  final Works work;
  
  const _WorkInformation({required this.work});

  @override
  Widget build(BuildContext context, WidgetRef ref ) {

    final workForm = ref.watch( workFormProvider( work ) );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: work.id != 'new'
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
                isTopField: true,
                isBottomField: true,
                label: 'Nombre',
                textSize: 16,
                    textShadows: const [
                      Shadow(
                        color: Color.fromARGB(255, 247, 211, 129), 
                        offset: Offset(0, 0), 
                        blurRadius: 2
                      )
                    ],
                hint: 'Nombre del trabajo',
                initialValue: workForm.name.value,
                onChanged: ref.read( workFormProvider( work ).notifier ).onNameChange,
                errorMessage: workForm.name.errorMessage,
              ),

              const SizedBox(height: 15 ),

              CustomProductField(
                isTopField: true,
                isBottomField: true,
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
                hint: 'Descripción del trabajo',
                initialValue: workForm.description.value,
                onChanged: ref.read( workFormProvider( work ).notifier ).onDescriptionChange,
                errorMessage: workForm.description.errorMessage,
              ),
              const SizedBox(height: 30 ),
            ],
          )
        : Column(
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
                isTopField: true,
                isBottomField: true,
                label: 'Nombre',
                textSize: 16,
                    textShadows: const [
                      Shadow(
                        color: Color.fromARGB(255, 247, 211, 129), 
                        offset: Offset(0, 0), 
                        blurRadius: 2
                      )
                    ],
                hint: 'Nombre del trabajo',
                onChanged: ref.read( workFormProvider( work ).notifier ).onNameChange,
                errorMessage: workForm.name.errorMessage,
              ),

              const SizedBox(height: 15 ),

              CustomProductField(
                maxLines: 6,
                isTopField: true,
                isBottomField: true,
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
                hint: 'Descripción del trabajo',
                onChanged: ref.read( workFormProvider( work ).notifier ).onDescriptionChange,
                errorMessage: workForm.description.errorMessage,
              ),
              const SizedBox(height: 30 ),
            ],
          )
    );
  }
}
