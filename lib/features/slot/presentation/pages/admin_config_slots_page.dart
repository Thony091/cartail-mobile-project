import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_button.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_card.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../domain/entities/slot.dart';
import '../../presentation/providers/slot_repository_provider.dart';
import '../providers/slots_provider.dart';

class AdminConfigSlotsPage extends ConsumerStatefulWidget {
  static const String name = 'AdminConfigSlotsPage';

  const AdminConfigSlotsPage({super.key});

  @override
  ConsumerState<AdminConfigSlotsPage> createState() =>
      _AdminConfigSlotsPageState();
}

class _AdminConfigSlotsPageState extends ConsumerState<AdminConfigSlotsPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slotsState = ref.watch(slotsProvider);
    final servicesState = ref.watch(servicesProvider);

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Espacios',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('AdminSlotCreationPage');
        },
        child: const Icon(Icons.add),
      ),
      body: slotsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : slotsState.error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(slotsState.error),
                      const SizedBox(height: 16),
                      ModernButton(
                        text: 'Reintentar',
                        style: ModernButtonStyle.primary,
                        onPressed: () => ref.refresh(slotsProvider),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Espacios Disponibles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por servicio o fecha...',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(
                                        () => _searchController.clear());
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      if (slotsState.slots.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_available_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay espacios disponibles',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Crea un nuevo espacio para comenzar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: slotsState.slots.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final slot = slotsState.slots[index];
                            final serviceName = servicesState.services
                                .firstWhere(
                                  (s) => s.id == slot.serviceId.toString(),
                                  orElse: () => servicesState.services.first,
                                )
                                .name;

                            return _SlotCard(
                              slot: slot,
                              serviceName: serviceName,
                              onEdit: () =>
                                  _editSlot(context, slot, ref),
                              onDelete: () =>
                                  _deleteSlot(context, slot, ref),
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }

  void _editSlot(
      BuildContext context, Slot slot, WidgetRef ref) {
    final servicesState = ref.watch(servicesProvider);
    DateTime? _selectedDate = DateTime.parse(slot.date);
    TimeOfDay? _startTime =
        _parseTimeOfDay(slot.startTime);
    TimeOfDay? _endTime = _parseTimeOfDay(slot.endTime);
    String? _serviceId = slot.serviceId.toString();
    bool _isSaving = false;
    String? _message;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Espacio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Servicio',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _serviceId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: servicesState.services.map((service) {
                    return DropdownMenuItem(
                      value: service.id,
                      child: Text(service.name),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => _serviceId = value),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => _selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Fecha del slot',
                    ),
                    child: Text(
                      _selectedDate != null
                          ? DateFormat('yyyy-MM-dd')
                              .format(_selectedDate!)
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
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _startTime ??
                                TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => _startTime = picked);
                          }
                        },
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
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _endTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => _endTime = picked);
                          }
                        },
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
          actions: [
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (_selectedDate == null ||
                          _serviceId == null ||
                          _startTime == null ||
                          _endTime == null) {
                        setDialogState(() =>
                            _message =
                                'Completa todos los campos.');
                        return;
                      }

                      final serviceIdStr =
                          _serviceId!.replaceFirst('local-', '');
                      final serviceId =
                          int.tryParse(serviceIdStr);
                      if (serviceId == null) {
                        setDialogState(() =>
                            _message = 'Servicio inválido.');
                        return;
                      }

                      setDialogState(() => _isSaving = true);

                      try {
                        final updatedSlot = Slot(
                          id: slot.id,
                          date: DateFormat('yyyy-MM-dd')
                              .format(_selectedDate!),
                          startTime:
                              _formatTime(_startTime!),
                          endTime: _formatTime(_endTime!),
                          serviceId: serviceId,
                        );

                        await ref
                            .read(slotRepositoryProvider)
                            .updateSlot(updatedSlot);

                        setDialogState(() =>
                            _message =
                                'Espacio actualizado con éxito.');

                        ref.refresh(slotsProvider);
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        debugPrint(
                            '❌ Error al actualizar el slot: $e');
                        setDialogState(() =>
                            _message =
                                'Error al actualizar.');
                      } finally {
                        setDialogState(() => _isSaving = false);
                      }
                    },
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSlot(
      BuildContext context, Slot slot, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Espacio'),
        content: Text(
            'Estás seguro de que deseas eliminar el espacio del ${slot.date} (${slot.startTime} - ${slot.endTime})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(slotRepositoryProvider)
                    .deleteSlot(slot.id);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Espacio eliminado con éxito.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  ref.refresh(slotsProvider);
                }
              } catch (e) {
                debugPrint('❌ Error al eliminar el slot: $e');
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar el espacio.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final Slot slot;
  final String serviceName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SlotCard({
    required this.slot,
    required this.serviceName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slot.date,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                      onTap: onEdit,
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text('${slot.startTime} - ${slot.endTime}'),
              backgroundColor: Colors.blue.shade100,
              labelStyle: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
