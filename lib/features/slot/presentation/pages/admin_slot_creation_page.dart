import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_button.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_card.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../domain/entities/slot.dart';
import '../../presentation/providers/slot_repository_provider.dart';
// import '../../../../shared/presentation/shared/widgets/modern_button.dart';
// import '../../../../shared/presentation/shared/widgets/modern_card.dart';

class AdminSlotCreationPage extends ConsumerStatefulWidget {
  static const String name = 'AdminSlotCreationPage';

  const AdminSlotCreationPage({super.key});

  @override
  ConsumerState<AdminSlotCreationPage> createState() =>
      _AdminSlotCreationPageState();
}

class _AdminSlotCreationPageState
    extends ConsumerState<AdminSlotCreationPage> {
  // final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _serviceId;
  String? _message;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesProvider);
    final serviceOptions = servicesState.services;

    return ModernScaffoldWithDrawer(
      title: 'Crear Horario',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nuevo Slot',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                'Servicio',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _serviceId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  hintText: 'Selecciona un servicio',
                ),
                items: serviceOptions.map((service) {
                  return DropdownMenuItem(
                    value: service.id,
                    child: Text(service.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _serviceId = value);
                },
                validator: (value) =>
                    value == null ? 'Selecciona un servicio' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Fecha del slot',
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : 'Selecciona una fecha',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? Colors.black87
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(isStart: true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Hora de inicio',
                        ),
                        child: Text(
                          _startTime != null
                              ? _formatTime(_startTime!)
                              : 'Inicio',
                          style: TextStyle(
                            color: _startTime != null
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(isStart: false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Hora de término',
                        ),
                        child: Text(
                          _endTime != null
                              ? _formatTime(_endTime!)
                              : 'Fin',
                          style: TextStyle(
                            color: _endTime != null
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ModernButton(
                text: 'Guardar Slot',
                style: ModernButtonStyle.primary,
                isLoading: _isSaving,
                onPressed: _saveSlot,
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains('éxito')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? initial) : (_endTime ?? initial),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveSlot() async {
    if (_selectedDate == null ||
        _serviceId == null ||
        _startTime == null ||
        _endTime == null) {
    setState(() => _message = 'Completa todos los campos obligatorios.');
      return;
    }
    // Parsear serviceId, eliminando prefijo "local-" si existe
    final serviceIdStr = _serviceId!.replaceFirst('local-', '');
    final serviceId = int.tryParse(serviceIdStr);
    if (serviceId == null) {
      setState(() => _message = 'Servicio inválido.');
      return;
    }
    final start = _formatTime(_startTime!);
    final end = _formatTime(_endTime!);
    final slot = Slot(
      id: 0,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      startTime: start,
      endTime: end,
      serviceId: serviceId,
    );
    setState(() {
      _isSaving = true;
      _message = null;
    });
    try {
      await ref.read(slotRepositoryProvider).createSlot(slot);
      setState(() {
        _message = 'Slot creado con éxito.';
        _serviceId = null;
        _selectedDate = null;
        _startTime = null;
        _endTime = null;
      });
    } catch (e) {
      debugPrint('❌ Error al crear el slot: $e');
      String errorMessage = 'Error al crear el slot.';

      // Intentar extraer mensaje del servidor si está disponible
      if (e.toString().contains('DioException')) {
        try {
          // Buscar el mensaje en el JSON de respuesta
          if (e.toString().contains('"message"')) {
            final match = RegExp(r'"message":"([^"]+)"').firstMatch(e.toString());
            if (match != null) {
              errorMessage = match.group(1) ?? errorMessage;
            }
          }
        } catch (_) {
          // Si falla el parsing, usar el mensaje completo pero limitado
          errorMessage = e.toString().length > 150
              ? e.toString().substring(0, 150) + '...'
              : e.toString();
        }
      } else {
        errorMessage = e.toString().length > 150
            ? e.toString().substring(0, 150) + '...'
            : e.toString();
      }

      setState(() => _message = errorMessage);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
