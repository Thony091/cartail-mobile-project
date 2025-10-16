import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/domain.dart';
import '../../../presentation_container.dart';
import '../../../shared/shared.dart';

class ReservationsCardService extends ConsumerWidget {

  final Reservation reservation;
  final Function()? onTapdEdit;
  final Function()? onTapDelete;

  const ReservationsCardService({
    super.key,
    required this.reservation,
    this.onTapdEdit,
    this.onTapDelete,
  });

  void showSnackbar( BuildContext context ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservación Eliminado')
      )
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(reservation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        child: const Align(
          child:  Padding(
            padding: EdgeInsets.only(left: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
                    showDialog(
            context: context, 
            builder: (context){
            
              return PopUpPreguntaWidget(
                pregunta: '¿Estas seguro de eliminar la reserva?',
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
        return Future.value(false);
      
      },
      
      child: Row(
        children: [
          _CardViewer( 
            name: reservation.name,
            rut: reservation.rut,
            email: reservation.email,
            serviceName: reservation.serviceName,
            reservationDate: reservation.reservationDate,
            reservationTime: reservation.reservationTime,
            onTapdEdit: onTapdEdit,
            onTapDelete: onTapDelete,
          ),
        ],
      ),
    );
  }
}


class _CardViewer extends StatelessWidget {

  final String name;
  final String rut;
  final String email;
  final String serviceName;
  final String reservationDate;
  final String reservationTime;
  final Function()? onTapdEdit;
  final Function()? onTapDelete;

  const _CardViewer({

    this.name = '', 
    this.rut = '',
    this.email = '',
    this.serviceName = '',
    this.reservationDate = '',
    this.reservationTime = '',
    this.onTapdEdit,
    this.onTapDelete,
  });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(width: size.width * 0.93,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 195, 224, 237),
              blurRadius: 5,
              offset: Offset(0, 3)
            ),
          ]
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          
              Container(
                width: size.width * 0.60,
                padding: const EdgeInsets.only( left: 5, top: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          
                    Text(
                      'Solicitante: $name',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox( height: 10 ),
                    Text(
                      maxLines: 3,
                      'Email: $rut',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox( height: 10 ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Solicitud de reserva:',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '  Servicio solicitado: $serviceName',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '  El día ${reservationDate.toString()} a las ${reservationTime.toString()} horas.',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Row( children:
                [
                  // const SizedBox( width: 10 ),
                  // CustomIconButton(
                  //   onTap: onTapdEdit ?? () {}, 
                  //   icon: Icons.edit,
                  //   size: 22,
                  //   color: Colors.blueGrey,
                  // ),
                  const SizedBox( width: 10 ),
                  CustomIconButton(
                    onTap: onTapDelete ?? () {}, 
                    icon: Icons.delete,
                    size: 22,
                    color: Colors.redAccent,
                  ),
                ]
              ),
            ],
          ),
        ),
      ),
    );

  }
}