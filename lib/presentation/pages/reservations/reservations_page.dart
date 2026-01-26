import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/custom_product_field.dart';

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

  /// Obtiene el primer mensaje de error de validación del formulario
  String? _getFirstValidationError(dynamic state, bool needsClientInfo) {
    // Orden de prioridad de validación
    if (state.vehiclePlate.errorMessage != null) {
      return state.vehiclePlate.errorMessage;
    }
    if (needsClientInfo) {
      if (state.clientName.errorMessage != null) {
        return state.clientName.errorMessage;
      }
      if (state.clientEmail.errorMessage != null) {
        return state.clientEmail.errorMessage;
      }
      if (state.clientPhone.errorMessage != null) {
        return state.clientPhone.errorMessage;
      }
    }
    if (state.serviceId.isEmpty) {
      return 'Debes seleccionar un servicio';
    }
    if (state.date.errorMessage != null) {
      return state.date.errorMessage;
    }
    if (state.time.errorMessage != null) {
      return state.time.errorMessage;
    }
    if (state.selectedSlotId == null) {
      return 'Debes seleccionar un horario disponible';
    }
    return null;
  }

  /// Muestra un mensaje de error usando SnackBar
  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Muestra un mensaje de éxito usando SnackBar
  void _showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Maneja el envío del formulario
  Future<void> _handleFormSubmit(
    BuildContext context,
    WidgetRef ref,
    bool needsClientInfo,
  ) async {
    final notifier = ref.read(reservationFormProvider.notifier);

    try {
      final success = await notifier.onFormSubmit();

      if (!context.mounted) return;

      if (success) {
        _showSuccessSnackBar(context, 'Reserva realizada con éxito');
        await Future.delayed(const Duration(milliseconds: 800));
        if (context.mounted) {
          context.push('/');
        }
      } else {
        // Leer el estado actualizado después del submit
        final currentState = ref.read(reservationFormProvider);
        final errorMessage = _getFirstValidationError(currentState, needsClientInfo);
        _showErrorSnackBar(context, errorMessage ?? 'Error al realizar la reserva');
      }
    } catch (e) {
      // Manejo de errores de red o servidor
      if (!context.mounted) return;
      _showErrorSnackBar(
        context,
        'Error de conexión. Por favor, intenta nuevamente.',
      );
    }
  }

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

  void _selectSlot(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.read(reservationFormProvider);
    if (state.availableSlots.isEmpty) {
      _showErrorSnackBar(context, 'No hay horarios disponibles');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: state.availableSlots.map((slot) {
              return ListTile(
                title: Text('${slot.startTime} - ${slot.endTime}'),
                onTap: () {
                  ref.read(reservationFormProvider.notifier).onSlotSelected(slot);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final servicios =  ref.watch( servicesProvider);
    final size = MediaQuery.of(context).size;
    final state = ref.watch(reservationFormProvider);
    final authState = ref.watch(betterAuthProvider);
    final isAuthenticated = authState.isAuthenticated;
    final userData = authState.session?.user;
    final needsClientInfo = !isAuthenticated ||
        userData == null ||
        userData.name!.isEmpty ||
        userData.email.isEmpty ||
        userData.phone!.isEmpty;

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
                        label: "Patente",
                        initialValue: state.vehiclePlate.value,
                        hint: "Patente del Vehículo",
                        onChanged: (value) {
                          ref.read( reservationFormProvider.notifier ).onVehiclePlateChange(value);
                        },
                      ),
                      const SizedBox(height: 10.0),

                      if (needsClientInfo) ...[
                        CustomProductField(
                          isBottomField: true,
                          isTopField: true,
                          label: "Nombre",
                          initialValue: state.clientName.value,
                          hint: "Nombre Completo",
                          onChanged: (value) {
                            ref.read(reservationFormProvider.notifier)
                              .onClientNameChange(value);
                          },
                        ),
                        const SizedBox(height: 10.0),

                        CustomProductField(
                          isBottomField: true,
                          isTopField: true,
                          label: "Correo Electrónico",
                          initialValue: state.clientEmail.value,
                          hint: "Correo Electrónico",
                          onChanged: (value) {
                            ref.read(reservationFormProvider.notifier)
                              .onClientEmailChange(value);
                          },
                        ),
                        const SizedBox(height: 10.0),

                        CustomProductField(
                          isBottomField: true,
                          isTopField: true,
                          label: "Teléfono",
                          initialValue: state.clientPhone.value,
                          hint: "Teléfono",
                          onChanged: (value) {
                            ref.read(reservationFormProvider.notifier)
                              .onClientPhoneChange(value);
                          },
                        ),
                        const SizedBox(height: 10.0),
                      ],
                        
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
                            value: state.serviceId.isNotEmpty
                              ? state.serviceId
                              : null,
                            items: servicios.services.map((service) {
                              return DropdownMenuItem<String>(
                                value: service.id,
                                child: Text(service.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              ref.read(reservationFormProvider.notifier)
                                .onServiceIdChange(value);
                            },
                          ),
                        ),
                      ), 
                      const SizedBox(height: 10.0),

                      if ( state.serviceId.isNotEmpty )
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
                            if (state.serviceId.isNotEmpty) {
                              _selectDate(context, ref);
                            } else {
                              _showErrorSnackBar(context, 'Primero selecciona el tipo de servicio');
                            }
                          },
                        ),
                      const SizedBox(height: 10.0),

                      if ( state.serviceId.isNotEmpty && state.date.value.isNotEmpty )
                        CustomProductField(
                          isBottomField: true,
                          isTopField: true,
                          readOnly: true,
                          label: "Horario",
                          hint: state.selectedSlotId != null
                              ? state.time.value
                              : "Selecciona un horario",
                          onTap: () {
                            if (state.date.value.isNotEmpty) {
                              _selectSlot(context, ref);
                            } else {
                              _showErrorSnackBar(context, 'Primero selecciona una fecha');
                            }
                          },
                          onChanged: (_) {},
                        ),
                      if (state.slotErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            state.slotErrorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
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
                  
                        onPressed: state.isPosting
                          ? null
                          : () => _handleFormSubmit(context, ref, needsClientInfo),
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
