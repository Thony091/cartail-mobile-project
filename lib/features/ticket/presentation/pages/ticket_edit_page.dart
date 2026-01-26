import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../auth/data/models/admin_response_models.dart';
import '../../../auth/presentation/providers/users_provider.dart';
import '../../../shared/domain/entities/state.dart' as lookup;
import '../../domain/entities/ticket.dart';
import '../providers/ticket_lookup_crud_providers.dart';
import '../providers/tickets_provider.dart';

class TicketEditPage extends ConsumerStatefulWidget {
  static const String name = 'TicketEditPage';

  final String ticketId;

  const TicketEditPage({super.key, required this.ticketId});

  @override
  ConsumerState<TicketEditPage> createState() => _TicketEditPageState();
}

class _TicketEditPageState extends ConsumerState<TicketEditPage> {
  int? _stateId;
  int? _importanceId;
  int? _urgencyId;
  String? _assignedOperatorId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider.notifier).loadUsers();
      ref.read(ticketEstadosCrudProvider.notifier).load(force: true);
      ref.read(ticketImportanciasCrudProvider.notifier).load(force: true);
      ref.read(ticketUrgenciasCrudProvider.notifier).load(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);
    final ticket = ticketsState.tickets.cast<Ticket?>().firstWhere(
          (t) => t?.id == widget.ticketId,
          orElse: () => null,
        );
    if (ticket == null) {
      return const ModernScaffoldWithDrawer(
        title: 'Editar Ticket',
        body: Center(child: Text('Ticket no encontrado')),
      );
    }

    final estados = ref.watch(ticketEstadosProvider);
    final importancias = ref.watch(ticketImportanciasProvider);
    final urgencias = ref.watch(ticketUrgenciasProvider);
    final operarios = ref.watch(operariosProvider);
    final operariosById = {
      for (final operator in operarios) operator.id: operator,
    };
    final isCompleted = _isCompleted(ticket);

    _stateId ??= ticket.stateId;
    _importanceId ??= ticket.importanceId;
    _urgencyId ??= ticket.urgencyId;
    _assignedOperatorId ??= ticket.assignedToId;
    final assignedOperatorValue = operariosById.containsKey(_assignedOperatorId)
        ? _assignedOperatorId
        : null;

    return ModernScaffoldWithDrawer(
      title: 'Editar Ticket',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isCompleted)
            const _InfoBanner(
              message: 'Este ticket ya está finalizado y no puede editarse.',
            ),
          _SectionCard(
            title: 'Asignación',
            child: DropdownButtonFormField<String>(
              value: assignedOperatorValue,
              decoration: const InputDecoration(
                labelText: 'Operario asignado',
                border: OutlineInputBorder(),
              ),
              items: operariosById.values
                  .map((operator) => DropdownMenuItem<String>(
                        value: operator.id,
                        child: Text(_operatorName(operator)),
                      ))
                  .toList(),
              onChanged: isCompleted ? null : (value) {
                setState(() => _assignedOperatorId = value);
              },
            ),
          ),
          _SectionCard(
            title: 'Estado',
            child: _buildLookupDropdown(
              label: 'Estado del ticket',
              value: _stateId,
              items: estados,
              enabled: !isCompleted,
              onChanged: (value) => setState(() => _stateId = value),
            ),
          ),
          _SectionCard(
            title: 'Importancia',
            child: _buildLookupDropdown(
              label: 'Importancia',
              value: _importanceId,
              items: importancias,
              enabled: !isCompleted,
              onChanged: (value) => setState(() => _importanceId = value),
            ),
          ),
          _SectionCard(
            title: 'Urgencia',
            child: _buildLookupDropdown(
              label: 'Urgencia',
              value: _urgencyId,
              items: urgencias,
              enabled: !isCompleted,
              onChanged: (value) => setState(() => _urgencyId = value),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isCompleted || _isSaving ? null : () => _save(ticket),
            child: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }

  bool _isCompleted(Ticket ticket) {
    final stateId = ticket.stateId ?? 1;
    return stateId == 4 || stateId == 5;
  }

  String _operatorName(AdminUserModel user) {
    final name = user.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return user.email;
  }

  Widget _buildLookupDropdown({
    required String label,
    required int? value,
    required List<lookup.State> items,
    required bool enabled,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem<int>(
                value: item.id,
                child: Text(item.name),
              ))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  Future<void> _save(Ticket ticket) async {
    if (_stateId == null || _importanceId == null || _urgencyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final operatorsById = ref.read(usersByIdProvider);
    final assignedUser = _assignedOperatorId != null
        ? operatorsById[_assignedOperatorId!]
        : null;

    final updatedTicket = ticket.copyWith(
      assignedToId: _assignedOperatorId,
      assignedToName: assignedUser != null ? _operatorName(assignedUser) : null,
      stateId: _stateId,
      importanceId: _importanceId,
      urgencyId: _urgencyId,
    );

    final ok = await ref.read(ticketsProvider.notifier).updateTicket(updatedTicket);
    if (!mounted) return;

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Ticket actualizado' : 'Error al actualizar ticket'),
      ),
    );
    if (ok) Navigator.pop(context);
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;

  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
