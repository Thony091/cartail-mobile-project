
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import 'modern_reservations_widgets.dart';
import '../providers/reservation_form_provider.dart';
import '../../../services/presentation/providers/services_provider.dart';
import 'reservation_payment_webview_page.dart';

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
                services: services,
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
    final notifier = ref.read(reservationFormProvider.notifier);

    try {
      final paymentSession = await notifier.onFormSubmit();

      if (!mounted) return;

      if (paymentSession != null) {
        final result = await context.push<ReservationPaymentResult>(
          '/reservation-payment',
          extra: paymentSession,
        );
        if (!mounted) return;
        if (result?.success == true) {
          _showSuccessDialog();
          _showSuccessSnackBar(result?.message ?? 'Pago confirmado.');
        } else if (result?.message != null) {
          _showSnackBar(result!.message!);
        }
      } else {
        final currentState = ref.read(reservationFormProvider);
        final errorMessage = currentState.errorMessage;
        if (errorMessage != null && errorMessage.isNotEmpty) {
          _showSnackBar(errorMessage);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error de conexión. Por favor, intenta nuevamente.');
    }
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF27ae60),
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
              '¡Pago Confirmado!',
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
