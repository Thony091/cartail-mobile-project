import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/pages/admin_pages/component/admin_card_reservation.dart';
import 'package:portafolio_project/presentation/presentation_container.dart';

import '../../../config/config.dart';

class ConfigReservationsPage extends ConsumerWidget {
  
  static const name = 'ConfigReservationsPage';

  const ConfigReservationsPage({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final color = AppTheme().getTheme().colorScheme;
    final reservationState = ref.watch( reservationProvider );
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracion de  reservas'),
        backgroundColor: color.primary,
      ),
      body: BackgroundImageWidget(
        opacity: 0.1,
        child: reservationState.reservations.isEmpty 
          ? FadeInRight(
              child: const Center(
                child: Text(
                  'No hay reservaciones en este momento', 
                  style: TextStyle(fontSize: 17),
                )
              )
            )
          : const _ReservationsPage(),
      ),
      drawer: SideMenu(scaffoldKey: scaffoldKey),
    );
  }
}

class _ReservationsPage extends ConsumerStatefulWidget {
  const _ReservationsPage();

  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<_ReservationsPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read( reservationProvider.notifier ).getReservations();
    });
  }

  void showSnackbar( BuildContext context ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservación Eliminado')
      )
    );
  }

@override
  Widget build(BuildContext context) {

    final reservationState = ref.watch( reservationProvider );
    
    return Padding(
      padding: const EdgeInsets.only( left: 20, top: 10, bottom: 15),
      child:  ListView.builder(
        itemCount: reservationState.reservations.length,
        itemBuilder: ( context, index) {
          final reservation = reservationState.reservations[index];
          return Column(
            children:
              [
                FadeInRight(
                  child: ReservationsCardService(
                    reservation: reservation,
                    // onTapdEdit: () => context.push('/service-edit/${service.id}'),
                    onTapDelete: () {
                      showDialog(
                        context: context, 
                        builder: (context){
                          return PopUpPreguntaWidget(
                            pregunta: '¿Estas seguro de eliminar el trabajo?', 
                            // confirmar: () {},
                            confirmar: () => ref.read(reservationProvider.notifier)
                              .deleteReservation(reservation.id)
                              .then((value) {
                                showSnackbar(context);
                                context.pop();
                              }), 
                            cancelar: () => context.pop()
                          );
                        }
                      );
                    } 
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