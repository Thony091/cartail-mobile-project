import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import 'modern_reservations_widgets.dart';

class ModernReservationsPage extends ConsumerStatefulWidget {
  static const name = 'ModernReservationsPage';

  const ModernReservationsPage({super.key});

  @override
  ModernReservationsPageState createState() => ModernReservationsPageState();
}

class ModernReservationsPageState
    extends ConsumerState<ModernReservationsPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ReservationFormState> _formStateKey = GlobalKey();

  bool _isLoading = false;

  final List<ServiceOption> _services = [
    ServiceOption('1', 'Detailing Completo', const Color(0xFF3498db)),
    ServiceOption('2', 'Lavado Express', const Color(0xFF27ae60)),
    ServiceOption('3', 'Pulido y Encerado', const Color(0xFFf39c12)),
    ServiceOption('4', 'Limpieza de Motor', const Color(0xFFe74c3c)),
    ServiceOption('5', 'Limpieza de Tapiz', const Color(0xFF9b59b6)),
  ];

  @override
  Widget build(BuildContext context) {
    return ModernScaffoldWithDrawer(
      title: 'Agenda tu Hora',
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              const ReservationHeader(),

              const SizedBox(height: 24),

              // Formulario de reserva
              ReservationForm(
                key: _formStateKey,
                services: _services,
                formKey: _formKey,
                isLoading: _isLoading,
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
    final formState = _formStateKey.currentState;
    if (formState == null) return;

    if (_formKey.currentState?.validate() ?? false) {
      if (!formState.validateSelections()) {
        if (formState.selectedDate == null) {
          _showSnackBar('Por favor selecciona una fecha');
          return;
        }
        if (formState.selectedTime == null) {
          _showSnackBar('Por favor selecciona una hora');
          return;
        }
      }

      setState(() {
        _isLoading = true;
      });

      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

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
                color: const Color(0xFF27ae60).withOpacity(0.1),
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
                  // Limpiar el formulario
                  _formStateKey.currentState?.reset();
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
