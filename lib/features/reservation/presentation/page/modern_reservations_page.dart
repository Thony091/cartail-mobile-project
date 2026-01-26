
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import 'modern_reservations_widgets.dart';
import '../providers/reservation_form_provider.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../services/domain/entities/services.dart';

class ModernReservationsPage extends ConsumerStatefulWidget {
  static const name = 'ModernReservationsPage';

  const ModernReservationsPage({super.key});

  @override
  ModernReservationsPageState createState() => ModernReservationsPageState();
}

class ModernReservationsPageState
    extends ConsumerState<ModernReservationsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesProvider);
    final services = servicesState.services;
    final serviceOptions = _buildServiceOptions(services);

    return ModernScaffoldWithDrawer(
      title: 'Agenda tu Hora',
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withValues(alpha: .1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              const ReservationHeader(),

              const SizedBox(height: 24),

              // Formulario de reserva
              ReservationForm(
                services: serviceOptions,
                formKey: _formKey,
                onSubmit: _handleReservation,
              ),

              const SizedBox(height: 24),

              // Información adicional
              const ReservationInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReservation() async {
    if (_formKey.currentState?.validate() ?? false) {
      final providerState = ref.read(reservationFormProvider);

      if (providerState.vehiclePlate.value.isEmpty) {
        _showSnackBar('Por favor ingresa la patente del vehículo');
        return;
      }

      if (providerState.serviceId.isEmpty) {
        _showSnackBar('Por favor selecciona un servicio');
        return;
      }

      if (providerState.selectedSlotId == null) {
        _showSnackBar('Por favor selecciona un horario disponible');
        return;
      }

      if (providerState.customerNotes.value.isEmpty) {
        _showSnackBar('Por favor ingresa las notas del cliente');
        return;
      }

      final created = await ref.read(reservationFormProvider.notifier).onFormSubmit();

      if (mounted && created) {
        _showSuccessDialog();
      } else if (mounted && !created) {
        _showSnackBar('No se pudo crear la reserva');
      }
    }
  }

  List<ServiceOption> _buildServiceOptions(List<Services> services) {
    const colors = [
      Color(0xFF3498db),
      Color(0xFF27ae60),
      Color(0xFFf39c12),
      Color(0xFFe74c3c),
      Color(0xFF9b59b6),
    ];

    return List.generate(services.length, (index) {
      final service = services[index];
      return ServiceOption(
        service.id,
        service.name,
        colors[index % colors.length],
      );
    });
  }

  // String _formatDate(DateTime date) {
  //   final year = date.year.toString().padLeft(4, '0');
  //   final month = date.month.toString().padLeft(2, '0');
  //   final day = date.day.toString().padLeft(2, '0');
  //   return '$year-$month-$day';
  // }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFe74c3c),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF27ae60).withValues(alpha: .1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: Color(0xFF27ae60),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Reserva Exitosa!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu reserva ha sido confirmada. Recibirás un correo con los detalles.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Entendido',
                style: ModernButtonStyle.success,
                  onPressed: () {
                    Navigator.of(context).pop();
                  ref.read(reservationFormProvider.notifier).resetForm();
                  _formKey.currentState?.reset();
                  },
                ),
              ),
            ],
        ),
      ),
    );
  }
}
