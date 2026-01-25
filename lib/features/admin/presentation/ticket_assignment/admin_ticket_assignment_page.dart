import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/better_auth_provider.dart';
import '../../../ticket/presentation/pages/widgets/ticket_widgets.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../domain/entities/admin_ticket_draft.dart';
import 'admin_ticket_assignment_controller.dart';

class AdminTicketAssignmentPage extends ConsumerStatefulWidget {
  static const String name = 'AdminTicketAssignmentPage';

  const AdminTicketAssignmentPage({super.key});

  @override
  ConsumerState<AdminTicketAssignmentPage> createState() =>
      _AdminTicketAssignmentPageState();
}

class _AdminTicketAssignmentPageState
    extends ConsumerState<AdminTicketAssignmentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminTicketAssignmentControllerProvider.notifier).loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(betterAuthProvider);
    final state = ref.watch(adminTicketAssignmentControllerProvider);
    final controller = ref.read(adminTicketAssignmentControllerProvider.notifier);

    if (!authState.isAdmin) {
      return ModernScaffoldWithDrawer(
        title: 'Asignación de Tickets',
        body: const Center(
          child: Text('Acceso exclusivo para administradores'),
        ),
      );
    }

    final filteredReservations = _applyReservationFilters(
      state.pendingReservations,
      state.filters,
    );
    final filteredTickets = _applyTicketFilters(
      state.createdTickets,
      state.filters,
    );
    final serviceOptions = _buildServiceOptions(
      state.pendingReservations,
      state.createdTickets,
    );

    return DefaultTabController(
      length: 2,
      child: ModernScaffoldWithDrawer(
        title: 'Asignación de Tickets',
        appBarActions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.loadInitial(force: true),
          ),
        ],
        body: Column(
          children: [
            _FiltersBar(
              filters: state.filters,
              serviceOptions: serviceOptions,
              onDateChange: controller.updateDateFilter,
              onServiceChange: controller.updateServiceFilter,
              onPriorityChange: controller.updatePriorityFilter,
            ),
            if ((state.errorMessage ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            const TabBar(
              tabs: [
                Tab(text: 'Pendientes'),
                Tab(text: 'Tickets creados'),
              ],
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _PendingReservationsList(
                          reservations: filteredReservations,
                          operators: state.operators,
                          onCreateTicket: _openCreateTicketDialog,
                        ),
                        _CreatedTicketsList(tickets: filteredTickets),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<AdminReservationSummary> _applyReservationFilters(
    List<AdminReservationSummary> reservations,
    AdminTicketAssignmentFilters filters,
  ) {
    return reservations.where((reservation) {
      final matchesService = filters.serviceType == 'Todas' ||
          reservation.serviceName == filters.serviceType;
      final matchesPriority = filters.priority == 'Todas' ||
          reservation.priority == filters.priority;
      final matchesDate = filters.date == null ||
          _isSameDate(reservation.date, filters.date!);
      return matchesService && matchesPriority && matchesDate;
    }).toList();
  }

  List<AdminTicketSummary> _applyTicketFilters(
    List<AdminTicketSummary> tickets,
    AdminTicketAssignmentFilters filters,
  ) {
    return tickets.where((ticket) {
      final matchesService = filters.serviceType == 'Todas' ||
          ticket.serviceName == filters.serviceType;
      final matchesPriority =
          filters.priority == 'Todas' || ticket.priority == filters.priority;
      final matchesDate = filters.date == null ||
          _isSameDate(ticket.date, filters.date!);
      return matchesService && matchesPriority && matchesDate;
    }).toList();
  }

  List<String> _buildServiceOptions(
    List<AdminReservationSummary> reservations,
    List<AdminTicketSummary> tickets,
  ) {
    final services = <String>{};
    for (final reservation in reservations) {
      if (reservation.serviceName.isNotEmpty) {
        services.add(reservation.serviceName);
      }
    }
    for (final ticket in tickets) {
      if (ticket.serviceName.isNotEmpty) {
        services.add(ticket.serviceName);
      }
    }
    final list = services.toList()..sort();
    return ['Todas', ...list];
  }

  bool _isSameDate(String value, DateTime target) {
    final parsed = _tryParseDate(value);
    if (parsed == null) return false;
    return parsed.year == target.year &&
        parsed.month == target.month &&
        parsed.day == target.day;
  }

  DateTime? _tryParseDate(String value) {
    if (value.isEmpty) return null;
    final direct = DateTime.tryParse(value);
    if (direct != null) return direct;
    if (value.length >= 10) {
      return DateTime.tryParse(value.substring(0, 10));
    }
    return null;
  }

  Future<void> _openCreateTicketDialog(
    BuildContext context,
    AdminReservationSummary reservation,
    List<AdminOperatorSummary> operators,
  ) async {
    final controller = ref.read(adminTicketAssignmentControllerProvider.notifier);
    final draft = await controller.buildDraft(reservation.id);
    if (!mounted) return;

    if (draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo generar el ticket.')),
      );
      return;
    }
    if (operators.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay operarios disponibles.')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => _CreateTicketDialog(
        reservation: reservation,
        draft: draft,
        operators: operators,
        onConfirm: (updatedDraft, operator) async {
          final ok = await controller.createAndAssignTicket(
            reservationId: reservation.id,
            draft: updatedDraft,
            operator: operator,
          );
          if (!dialogContext.mounted) return;
          if (ok) {
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket creado y asignado.')),
            );
          } else {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              const SnackBar(content: Text('No se pudo crear el ticket.')),
            );
          }
        },
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  final AdminTicketAssignmentFilters filters;
  final List<String> serviceOptions;
  final ValueChanged<DateTime?> onDateChange;
  final ValueChanged<String> onServiceChange;
  final ValueChanged<String> onPriorityChange;

  const _FiltersBar({
    required this.filters,
    required this.serviceOptions,
    required this.onDateChange,
    required this.onServiceChange,
    required this.onPriorityChange,
  });

  @override
  Widget build(BuildContext context) {
    final priorities = const ['Todas', 'Baja', 'Normal', 'Alta', 'Urgente'];
    final dateLabel = filters.date == null
        ? 'Fecha'
        : '${filters.date!.year}-${filters.date!.month.toString().padLeft(2, '0')}-${filters.date!.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(dateLabel),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: filters.date ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                onDateChange(picked);
              }
            },
          ),
          if (filters.date != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Limpiar fecha',
              onPressed: () => onDateChange(null),
            ),
          _DropdownFilter(
            label: 'Servicio',
            value: filters.serviceType,
            options: serviceOptions,
            onChanged: onServiceChange,
          ),
          _DropdownFilter(
            label: 'Prioridad',
            value: filters.priority,
            options: priorities,
            onChanged: onPriorityChange,
          ),
        ],
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: options
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
      ),
    );
  }
}

class _PendingReservationsList extends StatelessWidget {
  final List<AdminReservationSummary> reservations;
  final List<AdminOperatorSummary> operators;
  final void Function(
    BuildContext context,
    AdminReservationSummary reservation,
    List<AdminOperatorSummary> operators,
  ) onCreateTicket;

  const _PendingReservationsList({
    required this.reservations,
    required this.operators,
    required this.onCreateTicket,
  });

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return const Center(child: Text('No hay reservas pendientes.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        reservation.clientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const StatusBadge(
                      label: 'No creado',
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  reservation.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatReservationDate(reservation),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                if (reservation.summary.isNotEmpty)
                  Text(
                    reservation.summary,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PriorityChip(label: reservation.priority),
                    ElevatedButton.icon(
                      onPressed: () => onCreateTicket(
                        context,
                        reservation,
                        operators,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Crear ticket'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatReservationDate(AdminReservationSummary reservation) {
    final date = reservation.date.contains('T')
        ? reservation.date.split('T').first
        : reservation.date;
    if (reservation.reservationTime.isEmpty) return date;
    return '$date ${reservation.reservationTime}';
  }
}

class _CreatedTicketsList extends StatelessWidget {
  final List<AdminTicketSummary> tickets;

  const _CreatedTicketsList({required this.tickets});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const Center(child: Text('No hay tickets creados.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final statusLabel = ticket.isAssigned ? 'Asignado' : 'Sin asignar';
        final statusColor = ticket.isAssigned ? Colors.green : Colors.orange;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ticket.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    StatusBadge(label: statusLabel, color: statusColor),
                  ],
                ),
                const SizedBox(height: 8),
                Text(ticket.serviceName),
                const SizedBox(height: 4),
                Text(
                  ticket.date,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                if (ticket.description.isNotEmpty)
                  Text(
                    ticket.description,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PriorityChip(label: ticket.priority),
                    if (ticket.assignedToName != null)
                      Text(
                        'Operario: ${ticket.assignedToName}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;

  const _PriorityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _priorityColor(String value) {
    switch (value) {
      case 'Urgente':
        return Colors.redAccent;
      case 'Alta':
        return Colors.deepOrange;
      case 'Baja':
        return Colors.blueGrey;
      default:
        return Colors.blue;
    }
  }
}

class _CreateTicketDialog extends StatefulWidget {
  final AdminReservationSummary reservation;
  final AdminTicketDraft draft;
  final List<AdminOperatorSummary> operators;
  final Future<void> Function(AdminTicketDraft draft, AdminOperatorSummary operator)
      onConfirm;

  const _CreateTicketDialog({
    required this.reservation,
    required this.draft,
    required this.operators,
    required this.onConfirm,
  });

  @override
  State<_CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<_CreateTicketDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _priority;
  AdminOperatorSummary? _selectedOperator;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _descriptionController =
        TextEditingController(text: widget.draft.description);
    _priority = widget.draft.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priorities = const ['Baja', 'Normal', 'Alta', 'Urgente'];

    return AlertDialog(
      title: const Text('Crear ticket desde reserva'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${widget.reservation.clientName}'),
            const SizedBox(height: 4),
            Text('Servicio: ${widget.reservation.serviceName}'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titulo'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripcion'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _priority,
              items: priorities
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _priority = value ?? 'Normal'),
              decoration: const InputDecoration(labelText: 'Prioridad'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AdminOperatorSummary>(
              value: _selectedOperator,
              items: widget.operators
                  .map((operator) => DropdownMenuItem(
                        value: operator,
                        child: Text(operator.name),
                      ))
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedOperator = value),
              decoration: const InputDecoration(labelText: 'Operario asignado'),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: const TextStyle(color: Colors.redAccent)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  final title = _titleController.text.trim();
                  if (title.isEmpty || _selectedOperator == null) {
                    setState(() {
                      _errorText =
                          'Completa el titulo y selecciona un operario.';
                    });
                    return;
                  }
                  setState(() {
                    _isSubmitting = true;
                    _errorText = null;
                  });
                  final updatedDraft = widget.draft.copyWith(
                    title: title,
                    description: _descriptionController.text.trim(),
                    priority: _priority,
                  );
                  await widget.onConfirm(updatedDraft, _selectedOperator!);
                  if (!mounted) return;
                  setState(() => _isSubmitting = false);
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }
}
