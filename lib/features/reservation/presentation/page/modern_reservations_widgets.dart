import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/shared/domain/entities/state.dart' as lookup;
import 'package:portafolio_project/features/ticket/presentation/providers/ticket_lookup_crud_providers.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
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
    final authState = ref.watch(betterAuthProvider);
    final isAuthenticated = authState.isAuthenticated;
    final userData = authState.session?.user;
    final importancias = ref.watch(ticketImportanciasProvider);
    final urgencias = ref.watch(ticketUrgenciasProvider);
    final needsClientInfo = !isAuthenticated ||
        userData?.name == null ||
        userData?.email == null;
    final selectedService = formState.serviceId.isNotEmpty
        ? formState.serviceId
        : null;
    final selectedSlotId = formState.selectedSlotId;
    final selectedImportance = formState.importanceId;
    final selectedUrgency = formState.urgencyId;

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
                label: 'Patente del Vehículo (obligatorio)',
                hint: 'ABCD12',
                prefixIcon: const Icon(Icons.directions_car_outlined),
                errorMessage: formState.vehiclePlate.errorMessage,
                onChanged: formNotifier.onVehiclePlateChange,
              ),

              const SizedBox(height: 16),

              if (needsClientInfo) ...[
                ModernInputField(
                  label: 'Nombre del Cliente (obligatorio)',
                  hint: 'Ingresa tu nombre',
                  prefixIcon: const Icon(Icons.person_outline),
                  errorMessage: formState.clientName.errorMessage,
                  onChanged: formNotifier.onClientNameChange,
                ),
                const SizedBox(height: 16),
                ModernInputField(
                  label: 'Correo Electrónico (obligatorio)',
                  hint: 'ejemplo@correo.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  errorMessage: formState.clientEmail.errorMessage,
                  onChanged: formNotifier.onClientEmailChange,
                ),
                const SizedBox(height: 16),
                ModernInputField(
                  label: 'Teléfono (opcional)',
                  hint: '+56 9 1234 5678',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  onChanged: formNotifier.onClientPhoneChange,
                ),
                const SizedBox(height: 16),
              ],

              // Servicio
              const Text(
                'Selecciona el Servicio (obligatorio)',
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

              // Horarios disponibles
              const Text(
                'Selecciona un Horario (obligatorio)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 12),

              if (formState.isLoadingSlots)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (formState.availableSlots.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFe2e8f0)),
                  ),
                  child: const Text(
                    'No hay horarios disponibles para la fecha seleccionada.',
                    style: TextStyle(color: Color(0xFF7f8c8d)),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFe2e8f0)),
                  ),
                  child: DropdownButtonFormField<int>(
                    value: selectedSlotId,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      hintText: 'Elige un horario',
                    ),
                    items: formState.availableSlots.map((slot) {
                      return DropdownMenuItem(
                        value: slot.id,
                        child: Text(
                          '${slot.date} • ${slot.startTime} - ${slot.endTime}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      final slot = formState.availableSlots.firstWhere(
                        (item) => item.id == value,
                        orElse: () => formState.availableSlots.first,
                      );
                      formNotifier.onSlotSelected(slot);
                    },
                  ),
                ),
              if (formState.slotErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    formState.slotErrorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFe74c3c),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              const Text(
                'Selecciona Importancia (obligatorio)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 12),

              _buildLookupDropdown(
                items: importancias,
                value: selectedImportance,
                hintText: 'Elige una importancia',
                onChanged: formNotifier.onImportanceChange,
              ),

              const SizedBox(height: 16),

              const Text(
                'Selecciona Urgencia (obligatorio)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 12),

              _buildLookupDropdown(
                items: urgencias,
                value: selectedUrgency,
                hintText: 'Elige una urgencia',
                onChanged: formNotifier.onUrgencyChange,
              ),

              const SizedBox(height: 16),

              // Notas cliente
              ModernInputField(
                label: 'Notas del Cliente (obligatorio)',
                hint: 'Describe cualquier detalle importante...',
                maxLines: 4,
                prefixIcon: const Icon(Icons.sticky_note_2_outlined),
                errorMessage: formState.customerNotes.errorMessage,
                onChanged: formNotifier.onCustomerNotesChange,
              ),

              const SizedBox(height: 12),

              SwitchListTile.adaptive(
                value: formState.reminder,
                title: const Text('Recordatorio activado (obligatorio)'),
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

}

Widget _buildLookupDropdown({
  required List<lookup.State> items,
  required int? value,
  required String hintText,
  required ValueChanged<int?> onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFe2e8f0)),
    ),
    child: DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintText: hintText,
      ),
      items: items
          .map((item) => DropdownMenuItem<int>(
                value: item.id,
                child: Text(item.name),
              ))
          .toList(),
      validator: (value) {
        if (value == null) {
          return 'Campo obligatorio';
        }
        return null;
      },
      onChanged: onChanged,
    ),
  );
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
