import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/data/models/admin_response_models.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/auth/presentation/providers/users_provider.dart';
import 'package:portafolio_project/features/client/domain/entities/client.dart';
import 'package:portafolio_project/features/client/presentation/providers/clients_provider.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../state/presentation/providers/states_provider.dart';
import 'widgets/ticket_widgets.dart';
import '../providers/operator_ticket_progress_provider.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);
    final filtersState = ref.watch(ticketsFiltersProvider);
    final filtersNotifier = ref.read(ticketsFiltersProvider.notifier);
    final authState = ref.watch(betterAuthProvider);
    final operatorId = authState.session!.user.id;
    final operatorName = (authState.session!.user.name?.trim().isNotEmpty ?? false)
        ? authState.session!.user.name!.trim()
        : authState.session!.user.email;
    final assignedTickets =
        ticketsState.tickets.where((ticket) => ticket.assignedToId == operatorId);
    final usersById = ref.watch(usersByIdProvider);
    final clientsState = ref.watch(clientsProvider);
    final clientsById = <String, Client>{
      for (final client in clientsState.clients) client.id.toString(): client,
    };
    final filteredTickets =
        _filterTickets(assignedTickets.toList(), usersById, clientsById);
    final stats = _buildStats(filteredTickets);

    if (filtersState.isSearching && !_searchFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }

    return ModernScaffoldWithDrawer(
      title: 'Mis Tickets Asignados',
      titleWidget: filtersState.isSearching
          ? Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF3498db).withValues(alpha: 0.6),
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    cursorColor: const Color(0xFF2c3e50),
                    keyboardAppearance: Brightness.light,
                    textInputAction: TextInputAction.search,
                    onChanged: filtersNotifier.setSearchQuery,
                    style: const TextStyle(
                      color: Color(0xFF2c3e50),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Buscar ticket...',
                      hintStyle: TextStyle(color: Color(0xFF7f8c8d)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            )
          : null,
      appBarActions: [
        if (filtersState.isSearching)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              filtersNotifier.stopSearch();
              _searchController.clear();
              _searchFocusNode.unfocus();
            },
          )
        else
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              filtersNotifier.startSearch();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchFocusNode.requestFocus();
              });
            },
          ),
      ],
      body: GestureDetector(
        onTap:() => _searchFocusNode.unfocus(),
        child: Column(
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
              filterStatus: filtersState.filterStatus,
              onFilterChanged: filtersNotifier.setFilterStatus,
            ),
        
            const SizedBox(height: 16),
        
            // Lista de tickets asignados
            Expanded(
              child: ticketsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                : OperatorTicketsList(
                    tickets: filteredTickets,
                    operatorId: operatorId,
                    operatorName: operatorName,
                  ),
          ),
        ],
        ),
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

  List<Ticket> _filterTickets(
    List<Ticket> tickets,
    Map<String, AdminUserModel> usersById,
    Map<String, Client> clientsById,
  ) {
    return tickets.where((ticket) {
      final filtersState = ref.read(ticketsFiltersProvider);
      final stateId = ticket.stateId ?? 1;
      final matchesStatus = switch (filtersState.filterStatus) {
        'pending' => stateId == 1 || stateId == 2,
        'inProgress' => stateId == 3,
        'completed' => stateId == 4 || stateId == 5,
        _ => true,
      };

      final query = filtersState.searchQuery.trim().toLowerCase();
      final clientName = _resolveClientName(ticket, usersById, clientsById);
      final matchesSearch =
          query.isEmpty ||
          ticket.id.toLowerCase().contains(query) ||
          clientName.toLowerCase().contains(query) ||
          ticket.title.toLowerCase().contains(query) ||
          ticket.description.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  String _resolveClientName(
    Ticket ticket,
    Map<String, AdminUserModel> usersById,
    Map<String, Client> clientsById,
  ) {
    final explicit = ticket.userName.trim();
    if (explicit.isNotEmpty) return explicit;
    final metaName = _metadataValue(
      ticket,
      ['clientName', 'clienteNombre', 'nombre', 'cliente'],
    );
    if (metaName != null && metaName.trim().isNotEmpty) {
      return metaName.trim();
    }
    final userId = ticket.userId.trim();
    if (userId.isEmpty) return 'Sin nombre';
    final client = clientsById[userId];
    if (client != null) {
      final name = client.name.trim();
      if (name.isNotEmpty) return name;
      if (client.email.trim().isNotEmpty) return client.email.trim();
    }
    final user = usersById[userId];
    if (user == null) return 'Cliente no encontrado';
    final name = user.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return user.email;
  }

  String? _metadataValue(Ticket ticket, List<String> keys) {
    for (final key in keys) {
      final value = ticket.metadata[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
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
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'En Progreso',
              count: inProgressCount.toString(),
              icon: Icons.work,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
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

  String? _resolveOperatorName(Map<String, AdminUserModel> operatorsById) {
    final explicit = widget.ticket.assignedToName?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final assignedId = widget.ticket.assignedToId ?? widget.operatorId;
    if (assignedId.isEmpty) return null;

    final operator = operatorsById[assignedId];
    if (operator == null) return 'Operario no encontrado';

    final trimmed = operator.name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return operator.email;
  }

  String _resolveClientName(
    Map<String, AdminUserModel> usersById,
    Map<String, Client> clientsById,
  ) {
    final explicit = widget.ticket.userName.trim();
    if (explicit.isNotEmpty) return explicit;
    final metaName = _metadataValue(
      widget.ticket,
      ['clientName', 'clienteNombre', 'nombre', 'cliente'],
    );
    if (metaName != null && metaName.trim().isNotEmpty) {
      return metaName.trim();
    }
    final userId = widget.ticket.userId.trim();
    if (userId.isEmpty) return 'Sin nombre';
    final client = clientsById[userId];
    if (client != null) {
      final name = client.name.trim();
      if (name.isNotEmpty) return name;
      if (client.email.trim().isNotEmpty) return client.email.trim();
    }
    final user = usersById[userId];
    if (user == null) return 'Cliente no encontrado';
    final name = user.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return user.email;
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
    final usersById = ref.watch(usersByIdProvider);
    final resolvedOperatorName = _resolveOperatorName(usersById);
    final displayOperatorName = _normalizeName(
      resolvedOperatorName,
      fallback: _normalizeName(widget.operatorName, fallback: 'Operario no encontrado'),
    );
    final clientsState = ref.watch(clientsProvider);
    final clientsById = <String, Client>{
      for (final client in clientsState.clients) client.id.toString(): client,
    };
    final clientName = _resolveClientName(usersById, clientsById);

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
        onTap: () => _showTicketDetailSheet(
          context,
          displayOperatorName,
          clientName,
        ),
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
                    'Cliente: $clientName',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Asignado: $displayOperatorName',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showTicketDetailSheet(
                      context,
                      displayOperatorName,
                      clientName,
                    ),
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

  String _normalizeName(String? value, {required String fallback}) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isNotEmpty ? trimmed : fallback;
  }

  String? _metadataValue(Ticket ticket, List<String> keys) {
    for (final key in keys) {
      final value = ticket.metadata[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  Future<void> _showTicketDetailSheet(
    BuildContext context,
    String operatorName,
    String clientName,
  ) async {
    final states = ref.read(statesProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final progressState =
                ref.watch(operatorTicketProgressProvider(widget.ticket));
            final progressNotifier =
                ref.read(operatorTicketProgressProvider(widget.ticket).notifier);
            final stateName = states
                .firstWhere(
                  (state) => state.id == progressState.stateId,
                  orElse: () => states.first,
                )
                .name;
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.9,
              minChildSize: 0.6,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.ticket.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '#${widget.ticket.id}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _detailRow('Cliente', clientName),
                    _detailRow('Operario', operatorName),
                    _detailRow('Estado actual', stateName),
                    if (progressState.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        progressState.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Panel de Operario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: progressState.stateId,
                      decoration: const InputDecoration(
                        labelText: 'Cambiar estado',
                        border: OutlineInputBorder(),
                      ),
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
                        progressNotifier.changeState(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Checklist de avance',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (progressState.template.isEmpty)
                      const Text(
                        'No hay checklist para este estado.',
                        style: TextStyle(color: Colors.black54),
                      )
                    else
                      Column(
                        children: [
                          for (var i = 0; i < progressState.template.length; i++)
                            CheckboxListTile(
                              value: progressState.checkedItems.contains(i),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(progressState.template[i]),
                              onChanged: (value) {
                                if (value == null) return;
                                progressNotifier.toggleItem(i, value);
                              },
                            ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      'Comentarios generados',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (progressState.autoComments.isEmpty)
                      const Text(
                        'Aun no hay comentarios generados.',
                        style: TextStyle(color: Colors.black54),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: progressState.autoComments
                            .map(
                              (comment) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('• $comment'),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      'Comentario manual',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un comentario adicional...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: progressNotifier.updateManualComment,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.ticket.description.isNotEmpty
                          ? widget.ticket.description
                          : 'Sin descripción',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: progressState.isSaving
                                ? null
                                : () async {
                                    final ok = await progressNotifier
                                        .submitProgressUpdate(
                                      ticket: widget.ticket,
                                      operatorId: widget.operatorId,
                                      operatorName: operatorName,
                                    );
                                    if (!context.mounted) return;
                                    if (ok) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Avance actualizado correctamente'),
                                        ),
                                      );
                                    }
                                  },
                            icon: progressState.isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save, size: 18),
                            label: Text(
                              progressState.isSaving
                                  ? 'Guardando'
                                  : 'Guardar avances',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value.isNotEmpty ? value : '-')),
      ],
    ),
  );
}
