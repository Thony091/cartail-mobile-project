import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/reservation_form_provider.dart';

class ServiceOption {
  final String id;
  final String name;
  final Color color;

  ServiceOption(this.id, this.name, this.color);
}

class ReservationHeader extends StatelessWidget {
  const ReservationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: ModernCard(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF27ae60), Color(0xFF2ecc71)],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF27ae60).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_month,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Agenda tu Servicio!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona el servicio y la fecha que prefieras',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
            ),
          ],
        ),
      ),
    );
  }
}

class ReservationForm extends ConsumerWidget {
  final List<ServiceOption> services;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;

  const ReservationForm({
    super.key,
    required this.services,
    required this.formKey,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(reservationFormProvider);
    final formNotifier = ref.read(reservationFormProvider.notifier);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.authStatus == AuthStatus.authenticated;
    final userData = authState.userData;
    final needsClientInfo = !isAuthenticated ||
        userData == null ||
        userData.nombre.isEmpty ||
        userData.email.isEmpty ||
        userData.telefono.isEmpty;
    final selectedService = formState.serviceId.isNotEmpty
        ? formState.serviceId
        : null;
    final selectedDate = DateTime.tryParse(formState.date.value);
    final selectedTime = _parseTime(formState.time.value);

    return FadeInUp(
      child: ModernCard(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos de la Reserva',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 20),

              // Patente
              ModernInputField(
                label: 'Patente del Vehículo',
                hint: 'ABCD12',
                prefixIcon: const Icon(Icons.directions_car_outlined),
                errorMessage: formState.vehiclePlate.errorMessage,
                onChanged: formNotifier.onVehiclePlateChange,
              ),

              const SizedBox(height: 16),

              if (needsClientInfo) ...[
                ModernInputField(
                  label: 'Nombre del Cliente',
                  hint: 'Ingresa tu nombre',
                  prefixIcon: const Icon(Icons.person_outline),
                  errorMessage: formState.clientName.errorMessage,
                  onChanged: formNotifier.onClientNameChange,
                ),
                const SizedBox(height: 16),
                ModernInputField(
                  label: 'Correo Electrónico',
                  hint: 'ejemplo@correo.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  errorMessage: formState.clientEmail.errorMessage,
                  onChanged: formNotifier.onClientEmailChange,
                ),
                const SizedBox(height: 16),
                ModernInputField(
                  label: 'Teléfono',
                  hint: '+56 9 1234 5678',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  errorMessage: formState.clientPhone.errorMessage,
                  onChanged: formNotifier.onClientPhoneChange,
                ),
                const SizedBox(height: 16),
              ],

              // Servicio
              const Text(
                'Selecciona el Servicio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFe2e8f0)),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedService,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    hintText: 'Elige una opción',
                  ),
                  items: services.map((service) {
                    return DropdownMenuItem(
                      value: service.id,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: service.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(service.name),
                        ],
                      ),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor selecciona un servicio';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value != null) {
                      formNotifier.onServiceIdChange(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Fecha
              const Text(
                'Selecciona la Fecha',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: () => _selectDate(context, formNotifier, selectedDate),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFe2e8f0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF3498db),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        selectedDate != null
                            ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                            : 'Selecciona una fecha',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedDate != null
                              ? const Color(0xFF2c3e50)
                              : const Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hora
              const Text(
                'Selecciona la Hora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: () => _selectTime(
                  context,
                  formNotifier,
                  selectedTime ?? TimeOfDay.now(),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFe2e8f0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF3498db)),
                      const SizedBox(width: 16),
                      Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : 'Selecciona una hora',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedTime != null
                              ? const Color(0xFF2c3e50)
                              : const Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hora fin estimada
              const Text(
                'Hora Fin Estimada (opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 12),
              ModernInputField(
                label: 'Hora fin estimada',
                hint: '18:30',
                prefixIcon: const Icon(Icons.schedule),
                onChanged: formNotifier.onEndTimeEstimatedChange,
              ),

              const SizedBox(height: 16),

              // Notas cliente
              ModernInputField(
                label: 'Notas para el mecánico (opcional)',
                hint: 'Describe cualquier detalle importante...',
                maxLines: 4,
                prefixIcon: const Icon(Icons.sticky_note_2_outlined),
                onChanged: formNotifier.onCustomerNotesChange,
              ),

              const SizedBox(height: 12),

              SwitchListTile.adaptive(
                value: formState.reminder,
                title: const Text('Recordatorio activado'),
                onChanged: formNotifier.onReminderChange,
              ),

              const SizedBox(height: 24),

              // Botón de reservar
              SizedBox(
                width: double.infinity,
                child: ModernButton(
                  text: 'Reservar Ahora',
                  icon: Icons.check_circle,
                  style: ModernButtonStyle.success,
                  isLoading: formState.isPosting,
                  onPressed: onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    ReservationFormNotifier formNotifier,
    DateTime? currentDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3498db),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2c3e50),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != currentDate) {
      formNotifier.onReservationDate(picked);
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    ReservationFormNotifier formNotifier,
    TimeOfDay initialTime,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3498db),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2c3e50),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      formNotifier.onReservationTime(_formatTime(picked));
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay? _parseTime(String value) {
    if (value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

class ReservationInfoCard extends StatelessWidget {
  const ReservationInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Importante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              Icons.schedule,
              'Horario de Atención',
              'Lunes a Viernes: 9:00 - 19:00\nSábados: 9:00 - 14:00',
            ),
            _buildInfoItem(
              Icons.cancel,
              'Cancelaciones',
              'Puedes cancelar con 24 horas de anticipación',
            ),
            _buildInfoItem(
              Icons.payment,
              'Pago',
              'Se puede pagar en efectivo o tarjeta al momento del servicio',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF3498db), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7f8c8d),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
