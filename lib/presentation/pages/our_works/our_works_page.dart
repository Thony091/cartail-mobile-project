import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../config/config.dart';
import '../../presentation_container.dart';
import 'components/work_card.dart';
import 'components/work_user_card.dart';

class OurWorksPage extends ConsumerWidget {
  static const String name = 'OurWorksPage';
  const OurWorksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final scaffoldKey = GlobalKey<ScaffoldState>();
    final authState   = ref.watch( authProvider );
    final workState = ref.watch( worksProvider );
    final text  = AppTheme().getTheme().textTheme;
    // final color = AppTheme().getTheme().colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text( authState.authStatus != AuthStatus.authenticated
          ? "Nuestros Trabajos" 
          :( !authState.userData!.isAdmin )
            ? "Nuestros Trabajos" 
            : "Trabajos disponibles",
          style: text.titleLarge,
        ),
        elevation: 4.0,
        flexibleSpace: AppTheme.headerBgColor,
        // backgroundColor: color.primary,
      ),
      body:  BackgroundImageWidget(
        opacity: 0.35, 
        child: ( authState.authStatus != AuthStatus.authenticated)
          ? workState.works.isEmpty 
            ? FadeInRight(
                child: Center(
                  child: Text(
                    'No hay Trabajos en este momento', 
                    style: text.bodyMedium,
                  )
                )
              )
            : const _OurWorksBodyPage()
          : ( authState.userData!.isAdmin )
            ? workState.works.isEmpty 
              ? FadeInRight(
                  child: Center(
                    child: Text(
                      'No hay Trabajos en este momento', 
                      style: text.bodyMedium,
                    )
                  )
                )
              : const _OurWorksAdminBodyPage()
            : workState.works.isEmpty 
              ? FadeInRight(
                  child: Center(
                    child: Text(
                      'No hay Trabajos en este momento', 
                      style: text.bodyMedium,
                    )
                  )
                )
              : const _OurWorksBodyPage(),
      ),
      floatingActionButton: ( authState.authStatus != AuthStatus.authenticated)
        ? null 
        : ( authState.userData!.isAdmin ) 
          ? FloatingActionButton.extended(
              label: const Text('Crear Trabajo'),
              icon: const Icon( Icons.add ),
              onPressed: () => context.pushReplacement('/work-edit/new'),
            )
          : null,
      drawer: SideMenu( scaffoldKey: scaffoldKey ),
    );
  }
}

class _OurWorksBodyPage extends ConsumerWidget {

  const _OurWorksBodyPage();

  initState(WidgetRef ref){
    ref.read(worksProvider.notifier).getWorks();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final worksState = ref.watch( worksProvider );

    return Padding(
      padding: const EdgeInsets.symmetric( horizontal: 10 ),
      child: MasonryGridView.count(
        crossAxisCount: 1, 
        mainAxisSpacing: 20,
        itemCount: worksState.works.length,
        itemBuilder: (context, index) {
          final work = worksState.works[index];
          return GestureDetector(
            onTap: (){},
            child: FadeInRight(child: WorkUserCard( work: work ))
          );
        },
      ),
    );
  }
}


//* Vista de los Trabajos para el administrador
class _OurWorksAdminBodyPage extends ConsumerStatefulWidget {
  const _OurWorksAdminBodyPage();

  @override
  _OurWorksAdminBodyPageState createState() => _OurWorksAdminBodyPageState();
}

class _OurWorksAdminBodyPageState extends ConsumerState {

  @override
  Widget build(BuildContext context) {

    final worksState = ref.watch( worksProvider );
    void showDeleteSnackbar( BuildContext context ) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trabajo Eliminado')
        )
      );
    }
    
    return Padding(
      padding: const EdgeInsets.only( left: 20, top: 10),
      child:  ListView.builder(
        itemCount: worksState.works.length,
        itemBuilder: ( context, index) {
          final work = worksState.works[index];
          return Column(
            children: [
              const SizedBox(height: 10),
              FadeInRight(
                child: WorkCard( 
                  work: work,
                  onTapdEdit: () => context.push('/work-edit/${work.id}'),
                  onTapDelete: () => showDialog(
                    context: context, 
                    builder: (context) {
                      return PopUpPreguntaWidget(
                        pregunta: '¿Estas seguro de eliminar el Trabajo?', 
                        // confirmar: () {},
                        confirmar: () => ref.read( worksProvider.notifier )
                          .deleteWork(work.id)
                          .then((value) { 
                            showDeleteSnackbar( context );
                            context.pop();
                          }), 
                        cancelar: () => context.pop()
                      );
                    }
                  ),
                   
                ),
              ),
              // const SizedBox(height: 10),
            ] 
          );
        },
        
      ),
    );
  }
}