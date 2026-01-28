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
import '../../../services/domain/entities/services.dart';

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
  final List<Services> services;
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
    final importanciasAsync = ref.watch(ticketImportanciasProvider);
    final urgenciasAsync = ref.watch(ticketUrgenciasProvider);
    final needsClientInfo = !isAuthenticated ||
        userData?.name == null ||
        userData?.email == null;
    final selectedService = formState.serviceId.isNotEmpty
        ? formState.serviceId.replaceFirst('local-', '')
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

              // Error message display
              if (formState.isFormPosted && formState.errorMessage != null && formState.errorMessage!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe74c3c).withOpacity(0.1),
                    border: Border.all(color: const Color(0xFFe74c3c), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFe74c3c), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          formState.errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFe74c3c),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (formState.isFormPosted && formState.errorMessage != null && formState.errorMessage!.isNotEmpty)
                const SizedBox(height: 16),

              // Patente
              ModernInputField(
                label: 'Patente del Vehículo (obligatorio)',
                hint: 'ABCD12',
                prefixIcon: const Icon(Icons.directions_car_outlined),
                errorMessage: formState.isFormPosted ? formState.vehiclePlate.errorMessage : null,
                onChanged: formNotifier.onVehiclePlateChange,
              ),

              const SizedBox(height: 16),

              if (needsClientInfo) ...[
                ModernInputField(
                  label: 'Nombre del Cliente (obligatorio)',
                  hint: 'Ingresa tu nombre',
                  prefixIcon: const Icon(Icons.person_outline),
                  errorMessage: formState.isFormPosted ? formState.clientName.errorMessage : null,
                  onChanged: formNotifier.onClientNameChange,
                ),
                const SizedBox(height: 16),
                ModernInputField(
                  label: 'Correo Electrónico (obligatorio)',
                  hint: 'ejemplo@correo.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  errorMessage: formState.isFormPosted ? formState.clientEmail.errorMessage : null,
                  onChanged: formNotifier.onClientEmailChange,
                ),
                const SizedBox(height: 16),
                _PhoneInputField(
                  label: 'Teléfono (opcional)',
                  hint: '+56 9 1234 5678',
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
                  border: Border.all(
                    color: formState.isFormPosted && selectedService == null
                        ? const Color(0xFFe74c3c)
                        : const Color(0xFFe2e8f0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButton<String>(
                    value: selectedService,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Elige una opción'),
                    items: services.map((service) {
                      final cleanId = service.id.replaceFirst('local-', '');
                      return DropdownMenuItem(
                        value: cleanId,
                        child: Text(service.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        formNotifier.onServiceIdChange(value);
                      }
                    },
                  ),
                ),
              ),
              if (formState.isFormPosted && selectedService == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Por favor selecciona un servicio',
                    style: TextStyle(
                      color: Color(0xFFe74c3c),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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
                    border: Border.all(
                      color: formState.isFormPosted && selectedSlotId == null
                          ? const Color(0xFFe74c3c)
                          : const Color(0xFFe2e8f0),
                    ),
                  ),
                  child: DropdownButtonFormField<int>(
                    initialValue: selectedSlotId,
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
                )
              else if (formState.isFormPosted && selectedSlotId == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Debes seleccionar un horario disponible',
                    style: TextStyle(
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

              importanciasAsync.when(
                loading: () => _buildLoadingDropdown('Elige una importancia'),
                error: (err, stack) => _buildErrorDropdown('Error: ${err.toString()}'),
                data: (importancias) => _buildLookupDropdown(
                  items: importancias,
                  value: selectedImportance,
                  hintText: 'Elige una importancia',
                  onChanged: formNotifier.onImportanceChange,
                  isFormPosted: formState.isFormPosted,
                  isLoading: false,
                ),
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

              urgenciasAsync.when(
                loading: () => _buildLoadingDropdown('Elige una urgencia'),
                error: (err, stack) => _buildErrorDropdown('Error: ${err.toString()}'),
                data: (urgencias) => _buildLookupDropdown(
                  items: urgencias,
                  value: selectedUrgency,
                  hintText: 'Elige una urgencia',
                  onChanged: formNotifier.onUrgencyChange,
                  isFormPosted: formState.isFormPosted,
                  isLoading: false,
                ),
              ),

              const SizedBox(height: 16),

              // Notas cliente
              ModernInputField(
                label: 'Notas del Cliente (obligatorio)',
                hint: 'Describe cualquier detalle importante...',
                maxLines: 4,
                prefixIcon: const Icon(Icons.sticky_note_2_outlined),
                errorMessage: formState.isFormPosted ? formState.customerNotes.errorMessage : null,
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

/// Widget personalizado para entrada de teléfono con contador de dígitos
class _PhoneInputField extends StatefulWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const _PhoneInputField({
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<_PhoneInputField> {
  late TextEditingController _controller;
  int _digitCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_updateDigitCount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateDigitCount() {
    final digits = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() => _digitCount = digits.length);
    // Registra el valor completo en el formProvider
    widget.onChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2c3e50),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _digitCount > 0
                  ? const Color(0xFF27ae60).withValues(alpha: 0.5)
                  : const Color(0xFFe2e8f0),
              width: 2,
            ),
            boxShadow: _digitCount > 0
                ? [
                    BoxShadow(
                      color: const Color(0xFF27ae60).withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  color: Color(0xFF2c3e50),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        color: Color(0xFFbdc3c7),
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ),
                // Contador visual de dígitos
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _digitCount > 0
                        ? const Color(0xFF27ae60).withValues(alpha: 0.1)
                        : const Color(0xFFecf0f1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_digitCount dígitos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _digitCount > 0
                          ? const Color(0xFF27ae60)
                          : const Color(0xFF95a5a6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildLoadingDropdown(String hintText) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFe2e8f0)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}

Widget _buildErrorDropdown(String errorMessage) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFe74c3c)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFe74c3c), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            errorMessage,
            style: const TextStyle(
              color: Color(0xFFe74c3c),
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildLookupDropdown({
  required List<lookup.State> items,
  required int? value,
  required String hintText,
  required ValueChanged<int?> onChanged,
  required bool isFormPosted,
  required bool isLoading,
}) {
  final hasError = isFormPosted && value == null;

  if (isLoading) {
    return _buildLoadingDropdown(hintText);
  }

  if (items.isEmpty) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: const Text(
        'No hay opciones disponibles',
        style: TextStyle(color: Color(0xFF7f8c8d)),
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError
                ? const Color(0xFFe74c3c)
                : const Color(0xFFe2e8f0),
          ),
        ),
        child: DropdownButtonFormField<int>(
          initialValue: value,
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
            if (isFormPosted && value == null) {
              return 'Campo obligatorio';
            }
            return null;
          },
          onChanged: onChanged,
        ),
      ),
      if (hasError)
        const Padding(
          padding: EdgeInsets.only(top: 8, left: 12),
          child: Text(
            'Campo obligatorio',
            style: TextStyle(
              color: Color(0xFFe74c3c),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
    ],
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
              'El pago se realiza en línea al confirmar la reserva.',
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
