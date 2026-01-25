import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'widgets/ticket_widgets.dart';
import '../../../state/presentation/providers/states_provider.dart';
import '../providers/tickets_provider.dart';
import '../../domain/entities/ticket.dart';
import '../../../../presentation/presentation_container.dart';

/// Página para que el operario vea sus tickets asignados
class OperatorAssignedTicketsPage extends ConsumerStatefulWidget {
  static const String name = 'OperatorAssignedTicketsPage';

  const OperatorAssignedTicketsPage({super.key});

  @override
  OperatorAssignedTicketsPageState createState() =>
      OperatorAssignedTicketsPageState();
}

class OperatorAssignedTicketsPageState
    extends ConsumerState<OperatorAssignedTicketsPage> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);
    final authState = ref.watch(betterAuthProvider);
    final operatorId = authState.session!.user.id;
    final assignedTickets =
        ticketsState.tickets.where((ticket) => ticket.assignedToId == operatorId);
    final filteredTickets = _filterTickets(assignedTickets.toList());
    final stats = _buildStats(filteredTickets);

    return ModernScaffoldWithDrawer(
      title: 'Mis Tickets Asignados',
      body: Column(
        children: [
          // Resumen de tickets
          OperatorSummarySection(
            pendingCount: stats.pending,
            inProgressCount: stats.inProgress,
            completedCount: stats.completed,
          ),

          const SizedBox(height: 16),

          // Filtros
          OperatorFiltersSection(
            filterStatus: _filterStatus,
            onFilterChanged: (value) => setState(() => _filterStatus = value),
          ),

          const SizedBox(height: 16),

          // Lista de tickets asignados
          Expanded(
            child: ticketsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : OperatorTicketsList(
                    tickets: filteredTickets,
                    operatorId: operatorId,
                    operatorName: authState.session!.user.name ?? 'Operario',
                  ),
          ),
        ],
      ),
    );
  }

  _TicketStats _buildStats(List<Ticket> tickets) {
    int pending = 0;
    int inProgress = 0;
    int completed = 0;

    for (final ticket in tickets) {
      final stateId = ticket.stateId ?? 1;
      if (stateId == 1 || stateId == 2) {
        pending++;
      } else if (stateId == 3) {
        inProgress++;
      } else if (stateId == 4 || stateId == 5) {
        completed++;
      }
    }

    return _TicketStats(
      pending: pending,
      inProgress: inProgress,
      completed: completed,
    );
  }

  List<Ticket> _filterTickets(List<Ticket> tickets) {
    return tickets.where((ticket) {
      final stateId = ticket.stateId ?? 1;
      return switch (_filterStatus) {
        'pending' => stateId == 1 || stateId == 2,
        'inProgress' => stateId == 3,
        'completed' => stateId == 4 || stateId == 5,
        _ => true,
      };
    }).toList();
  }
}

class _TicketStats {
  final int pending;
  final int inProgress;
  final int completed;

  _TicketStats({
    required this.pending,
    required this.inProgress,
    required this.completed,
  });
}

/// Sección de resumen para operarios
class OperatorSummarySection extends StatelessWidget {
  final int pendingCount;
  final int inProgressCount;
  final int completedCount;

  const OperatorSummarySection({
    super.key,
    required this.pendingCount,
    required this.inProgressCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SummaryCard(
              title: 'Pendientes',
              count: pendingCount.toString(),
              icon: Icons.pending,
              color: Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'En Progreso',
              count: inProgressCount.toString(),
              icon: Icons.work,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'Completados Hoy',
              count: completedCount.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección de filtros para operarios
class OperatorFiltersSection extends StatelessWidget {
  final String filterStatus;
  final ValueChanged<String> onFilterChanged;

  const OperatorFiltersSection({
    super.key,
    required this.filterStatus,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: 'Todos',
            selected: filterStatus == 'all',
            onTap: () => onFilterChanged('all'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: 'Pendientes',
            selected: filterStatus == 'pending',
            onTap: () => onFilterChanged('pending'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: 'En Progreso',
            selected: filterStatus == 'inProgress',
            onTap: () => onFilterChanged('inProgress'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: 'Completados',
            selected: filterStatus == 'completed',
            onTap: () => onFilterChanged('completed'),
          ),
        ],
      ),
    );
  }
}

/// Lista de tickets asignados al operario
class OperatorTicketsList extends StatelessWidget {
  final List<Ticket> tickets;
  final String operatorId;
  final String operatorName;

  const OperatorTicketsList({
    super.key,
    required this.tickets,
    required this.operatorId,
    required this.operatorName,
  });

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const Center(child: Text('No hay tickets asignados'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return OperatorTicketCard(
          ticket: tickets[index],
          index: index,
          operatorId: operatorId,
          operatorName: operatorName,
        );
      },
    );
  }
}

/// Tarjeta de ticket para vista de operario
class OperatorTicketCard extends ConsumerStatefulWidget {
  final int index;
  final Ticket ticket;
  final String operatorId;
  final String operatorName;

  const OperatorTicketCard({
    super.key,
    required this.index,
    required this.ticket,
    required this.operatorId,
    required this.operatorName,
  });

  @override
  ConsumerState<OperatorTicketCard> createState() => _OperatorTicketCardState();
}

class _OperatorTicketCardState extends ConsumerState<OperatorTicketCard> {
  late int _selectedStateId;

  @override
  void initState() {
    super.initState();
    _selectedStateId = widget.ticket.stateId ?? ((widget.index % 5) + 1);
  }

  Color _getStatusColor(int stateId) {
    switch (stateId) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.green;
      case 5:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final states = ref.watch(statesProvider);
    final selectedStateName = states
            .firstWhere(
              (state) => state.id == _selectedStateId,
              orElse: () => states.first,
            )
            .name;
    final isPriority = widget.index % 3 == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPriority
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navegar a detalle del ticket
          // context.push('/ticket/$ticketId');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isPriority) ...[
                    const PriorityBadge(),
                    const SizedBox(width: 8),
                  ],
                  StatusBadge(
                    label: selectedStateName,
                    color: _getStatusColor(_selectedStateId),
                  ),
                  const Spacer(),
                  Text(
                    'Ticket #${widget.ticket.id}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Text(
                    'Estado:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int>(
                      value: _selectedStateId,
                      isExpanded: true,
                      items: states
                          .map(
                            (state) => DropdownMenuItem(
                              value: state.id,
                              child: Text(state.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedStateId = value);
                        ref.read(ticketsProvider.notifier).updateTicketStatus(
                          ticket: widget.ticket,
                          stateId: value,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Estado actualizado a ${states.firstWhere((s) => s.id == value, orElse: () => states.first).name}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.ticket.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Cliente: ${widget.ticket.userName.isNotEmpty ? widget.ticket.userName : 'Sin nombre'}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Asignado: ${widget.ticket.assignedToName ?? widget.operatorName}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showCommentDialog(context),
                    icon: const Icon(Icons.comment, size: 18),
                    label: const Text('Comentario'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3498db),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Ver detalle
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ver Detalle'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3498db),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCommentDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar comentario'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe el avance o detalle...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa un comentario';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final ok = await ref.read(ticketsProvider.notifier).addTicketComment(
                      ticket: widget.ticket,
                      comment: controller.text.trim(),
                      authorId: widget.operatorId,
                      authorName: widget.operatorName,
                    );
                if (!context.mounted) return;
                if (ok) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comentario agregado')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
