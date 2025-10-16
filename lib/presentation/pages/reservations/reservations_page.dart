import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/shared/widgets/custom_product_field.dart';

import '../../../config/config.dart';
import '../../presentation_container.dart';


//*TODO Revisar la implementación de la página de reservas*****

class ReservationsPage extends ConsumerWidget {

  static const name = 'ReservationsPage';
  
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // final scaffoldKey = GlobalKey<ScaffoldState>();
    // final color = AppTheme().getTheme().colorScheme;
    final text  = AppTheme().getTheme().textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Reservations Page",
            style: text.titleLarge,
          ),
          elevation: 4.0,
          flexibleSpace: AppTheme.headerBgColor,
          // backgroundColor: color.primary,
        ),
        body: BackgroundImageWidget(
          opacity: 0.45,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const SizedBox(height: 30.0),
                FadeInDown(
                  child: const CustomTextWithEffect(
                    text: "Haz tu Reserva", 
                    textStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
                Center(
                  child:  FadeInUp(
                    child: const _ReservationFormBody()
                  ),
                ),
              ],
            ),
          ),
        ),
        // drawer: SideMenu(scaffoldKey: scaffoldKey),
      ),
    );
  }
}

class _ReservationFormBody extends ConsumerWidget {

  const _ReservationFormBody();

  Future<void> _selectDate( BuildContext context, WidgetRef ref ) async {
    DateTime now = DateTime.now();
    // Asegurarnos de que la fecha inicial sea un día de lunes a sábado
    DateTime initialDate = now;
    while (initialDate.weekday == DateTime.sunday) {
      initialDate = initialDate.add(const Duration(days: 1));
    }
    DateTime firstDate = DateTime(now.year, now.month, now.day);
    DateTime lastDate = DateTime(now.year + 1, now.month, now.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (day) {
        return day.weekday != DateTime.sunday;
      },
    );

    if ( pickedDate != null ) {
      ref.read(reservationFormProvider.notifier).onReservationDate(pickedDate);
    }
  }

  Future<void> _selectTime( BuildContext context, WidgetRef ref ) async {

    final List<String> timeOptions = [];
    for (int hour = 9; hour <= 18; hour++) {
      timeOptions.add('$hour:00');
      timeOptions.add('$hour:30');
    }

    if ( timeOptions.isEmpty ) return;

    final String? pickedTime = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: timeOptions.map((time) {
              return ListTile(
                title: Text(time),
                onTap: () {
                  Navigator.of(context).pop(time);
                },
              );
            }).toList(),
          ),
        );
      },
    );
    if (pickedTime != null) {
      ref.read(reservationFormProvider.notifier).onReservationTime(pickedTime);
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final servicios =  ref.watch( servicesProvider);
    final opciones = servicios.services.map((e) => e.name).toList();
    final size = MediaQuery.of(context).size;
    final state = ref.watch(reservationFormProvider);
    final authState = ref.watch(authProvider);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag ,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0
        ), 
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  // height: size.height * 0.85,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 223, 223, 223),
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: Colors.black45),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        label: "Name",
                        initialValue: authState.authStatus == AuthStatus.authenticated
                          ? authState.userData!.nombre
                          : state.name.value,
                        hint: "Nombre Completo",
                        onChanged: (value) {
                          ref.read( reservationFormProvider.notifier ).onNameChange(value);
                        },
                      ),
                      const SizedBox(height: 10.0),
                        
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        label: "Rut",
                        initialValue: authState.authStatus == AuthStatus.authenticated
                          ? authState.userData!.rut
                          : state.rut.value,
                        hint: "Rut",
                        onChanged: (value) {
                          ref.read( reservationFormProvider.notifier ).onRutChange(value);
                        },
                      ),
                      const SizedBox(height: 10.0),
                        
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        initialValue: authState.authStatus == AuthStatus.authenticated
                          ? authState.userData!.email
                          : state.email.value,
                        label: "Correo Electrónico",
                        hint: "Correo Electrónico",
                        onChanged: (value) {
                          ref.read( reservationFormProvider.notifier ).onEmailChange(value);
                        },
                      ),
                      const SizedBox(height: 10.0),
                        
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 60.0,
                        width: size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black45),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text('Elije una opción'),
                            value: state.serviceName.isNotEmpty
                              ? state.serviceName
                              : null,
                            items: opciones.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              ref.read(reservationFormProvider.notifier)
                                .onServiceNameChange(value!);
                            },
                          ),
                        ),
                      ), 
                      const SizedBox(height: 10.0),

                      if ( state.serviceName.isNotEmpty )
                        CustomProductField(
                          isBottomField: true,
                          isTopField: true,
                          readOnly: true,
                          label: state.date.value.isNotEmpty ? state.date.value : "Fecha de Reserva",
                          // initialValue: state.date.value,
                          hint: state.date.value.isNotEmpty ? state.date.value : "Fecha de Reserva",
                          onChanged: (value) {
                            ref.read( reservationFormProvider.notifier ).onReservationDate(DateTime.parse(value));
                          },
                          onTap: () {
                            if (state.serviceName.isNotEmpty) {
                              _selectDate(context, ref);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Primero selecciona el tipo de servicio'))
                              );
                            }
                          },
                        ),
                      const SizedBox(height: 10.0),

                      if ( state.serviceName.isNotEmpty && state.date.value.isNotEmpty )
                        CustomProductField(
                          isBottomField: true,
                          isTopField: true,
                          readOnly: true,
                          label: "Hora",
                          // initialValue: state.time.value.isNotEmpty ? state.time.value : "Hora de Reserva",
                          hint: state.time.value.isNotEmpty ? state.time.value : "",
                          onTap: () {
                            if (state.date.value.isNotEmpty) {
                              _selectTime(context, ref);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Primero selecciona una fecha'))
                              );
                            }
                          },
                          onChanged: (value) {
                            ref.read( reservationFormProvider.notifier ).onReservationTime(value);
                          },
                        ),
                        
                      const SizedBox(height: 25.0),
                      CustomFilledButton(
                        height: 65.0,
                        width: size.width * 0.8,
                        text: "Reservar",
                        fontSize: 22.0,
                        shadowColor: Colors.white,
                        spreadRadius: 4,
                        blurRadius: 3,
                        radius: const Radius.circular(30),
                        iconSeparatorWidth: 70,
                        icon: Icons.calendar_month_outlined,
                        buttonColor: Colors.blueAccent.shade400,
                  
                        onPressed: () {
                          ref.read(reservationFormProvider.notifier).createReservation().then(
                            (value) {
                              if (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Reserva realizada con éxito"),
                                    backgroundColor: Colors.green,
                                  )
                                );
                                context.push('/');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text( 
                                      state.date.errorMessage != null 
                                        ? state.date.errorMessage.toString()
                                        : ( state.time.errorMessage != null ) 
                                          ? state.time.errorMessage.toString()
                                          : ( state.name.errorMessage != null ) 
                                            ? state.name.errorMessage.toString()
                                            : ( state.email.errorMessage != null ) 
                                              ? state.email.errorMessage.toString()
                                              : ( state.rut.errorMessage != null ) 
                                                ? state.rut.errorMessage.toString()
                                                : "Error al realizar la reserva"
                                    ),
                                    backgroundColor: Colors.red,
                                  )
                                );
                              }
                            
                            }
                          );
                          // ref.read(goRouterProvider).go('/reservations');
                        },
                      ),
                      const SizedBox(height: 20.0),
                      
                      if (state.isPosting)
                        const CircularProgressIndicator(),
                      const SizedBox(height: 20.0),

                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
              ]
            ),
          ]
        )
      ),
    );
  }
}


