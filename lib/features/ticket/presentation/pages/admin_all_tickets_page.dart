import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'widgets/ticket_widgets.dart';
import '../../../state/presentation/providers/states_provider.dart';
import '../providers/tickets_provider.dart';
import '../providers/operator_users_provider.dart';
import '../../domain/entities/ticket.dart';

/// Página para que el administrador vea todos los tickets del sistema
class AdminAllTicketsPage extends ConsumerStatefulWidget {
  static const String name = 'AdminAllTicketsPage';

  const AdminAllTicketsPage({super.key});

  @override
  AdminAllTicketsPageState createState() => AdminAllTicketsPageState();
}

class AdminAllTicketsPageState extends ConsumerState<AdminAllTicketsPage> {
  String _filterStatus = 'all';
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);
    final filteredTickets = _filterTickets(ticketsState.tickets);
    final stats = _buildStats(ticketsState.tickets);

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Tickets',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => _showSearchDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () => _showFilterDialog(context),
        ),
      ],
      body: Column(
        children: [
          // Estadísticas
          TicketStatisticsSection(
            pendingCount: stats.pending,
            inProgressCount: stats.inProgress,
            completedCount: stats.completed,
          ),

          const SizedBox(height: 16),

          // Filtros rápidos
          QuickFiltersSection(
            filterStatus: _filterStatus,
            onFilterChanged: (value) => setState(() => _filterStatus = value),
          ),

          const SizedBox(height: 16),

          // Lista de tickets
          Expanded(
            child: ticketsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : AdminTicketsList(tickets: filteredTickets),
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
      if (stateId == 1) {
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
      final matchesStatus = switch (_filterStatus) {
        'pending' => stateId == 1,
        'assigned' => stateId == 2,
        'inProgress' => stateId == 3,
        'completed' => stateId == 4 || stateId == 5,
        _ => true,
      };

      final matchesType = switch (_filterType) {
        'reservation' => ticket.type == TicketType.reservation,
        'purchase' => ticket.type == TicketType.purchase,
        'order' => ticket.type == TicketType.order,
        _ => true,
      };

      return matchesStatus && matchesType;
    }).toList();
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Ticket'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'ID de ticket o nombre de cliente',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Aplicar búsqueda
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros Avanzados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _filterType,
              decoration: const InputDecoration(labelText: 'Tipo de Ticket'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Todos')),
                DropdownMenuItem(value: 'reservation', child: Text('Reservas')),
                DropdownMenuItem(value: 'purchase', child: Text('Compras')),
                DropdownMenuItem(value: 'order', child: Text('Pedidos')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _filterType = value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Aplicar filtros
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
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

/// Sección de estadísticas de tickets
class TicketStatisticsSection extends StatelessWidget {
  final int pendingCount;
  final int inProgressCount;
  final int completedCount;

  const TicketStatisticsSection({
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
            child: StatisticCard(
              title: 'Pendientes',
              count: pendingCount.toString(),
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: StatisticCard(
              title: 'En Progreso',
              count: inProgressCount.toString(),
              icon: Icons.engineering,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: StatisticCard(
              title: 'Completados',
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

/// Sección de filtros rápidos
class QuickFiltersSection extends StatelessWidget {
  final String filterStatus;
  final ValueChanged<String> onFilterChanged;

  const QuickFiltersSection({
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
            label: 'Asignados',
            selected: filterStatus == 'assigned',
            onTap: () => onFilterChanged('assigned'),
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

/// Lista de tickets para administrador
class AdminTicketsList extends StatelessWidget {
  final List<Ticket> tickets;

  const AdminTicketsList({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const Center(child: Text('No hay tickets'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return AdminTicketCard(ticket: tickets[index], index: index);
      },
    );
  }
}

/// Tarjeta de ticket para vista de administrador
class AdminTicketCard extends ConsumerStatefulWidget {
  final int index;
  final Ticket ticket;

  const AdminTicketCard({super.key, required this.index, required this.ticket});

  @override
  ConsumerState<AdminTicketCard> createState() => _AdminTicketCardState();
}

class _AdminTicketCardState extends ConsumerState<AdminTicketCard> {
  late int _selectedStateId;
  late Ticket _ticket;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    _selectedStateId = widget.ticket.stateId ?? ((widget.index % 5) + 1);
  }

  Future<void> _showAssignOperatorDialog(BuildContext context) async {
    ref.read(operatorUsersProvider.notifier).loadOperators();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final operatorsState = ref.watch(operatorUsersProvider);

            if (operatorsState.isLoading && operatorsState.operators.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (operatorsState.errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  operatorsState.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            if (operatorsState.operators.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No hay operarios disponibles'),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Asignar operario',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: operatorsState.operators.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final operator = operatorsState.operators[index];
                          final operatorName =
                              operator.name?.trim().isNotEmpty == true
                                  ? operator.name!.trim()
                                  : operator.email;
                          return ListTile(
                            leading: const Icon(Icons.engineering_outlined),
                            title: Text(operatorName),
                            subtitle: Text(operator.email),
                            onTap: () async {
                              final ok = await ref
                                  .read(ticketsProvider.notifier)
                                  .assignOperator(
                                    ticket: _ticket,
                                    operatorId: operator.id,
                                    operatorName: operatorName,
                                  );
                              if (!context.mounted) return;
                              if (ok) {
                                setState(() {
                                  _ticket = _ticket.copyWith(
                                    assignedToId: operator.id,
                                    assignedToName: operatorName,
                                    stateId: _ticket.stateId == null ||
                                            _ticket.stateId == 1
                                        ? 2
                                        : _ticket.stateId,
                                  );
                                  _selectedStateId = _ticket.stateId ?? 2;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Ticket asignado a $operatorName'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

  String _getTypeLabel(TicketType type) {
    switch (type) {
      case TicketType.reservation:
        return 'Reserva';
      case TicketType.purchase:
        return 'Compra';
      case TicketType.order:
        return 'Pedido';
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  StatusBadge(
                    label: selectedStateName,
                    color: _getStatusColor(_selectedStateId),
                  ),
                  const SizedBox(width: 8),
                  TypeBadge(label: _getTypeLabel(widget.ticket.type)),
                  const Spacer(),
                  Text(
                    'Ticket #${_ticket.id}',
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
                    'Estado del ticket:',
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
                          ticket: _ticket,
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
                _ticket.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Cliente: ${_ticket.userName.isNotEmpty ? _ticket.userName : 'Sin nombre'}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.engineering, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _ticket.assignedToName != null && _ticket.assignedToName!.isNotEmpty
                        ? 'Asignado a: ${_ticket.assignedToName}'
                        : 'Sin asignar',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showAssignOperatorDialog(context),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Asignar'),
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
}
