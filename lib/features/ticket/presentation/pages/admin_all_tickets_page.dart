import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/client/domain/entities/client.dart';
import 'package:portafolio_project/features/client/presentation/providers/clients_provider.dart';
import 'package:portafolio_project/features/reservation/domain/entities/reservation.dart';
import 'package:portafolio_project/features/reservation/presentation/providers/reservation_derived_providers.dart';
import 'package:portafolio_project/features/reservation/presentation/providers/reservation_provider.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'widgets/ticket_widgets.dart';
import '../providers/tickets_provider.dart';
import 'package:portafolio_project/features/auth/presentation/providers/users_provider.dart';
import '../../domain/entities/ticket.dart';
import '../providers/ticket_lookup_crud_providers.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../shared/domain/entities/state.dart' as lookup;
import '../../../services/domain/entities/services.dart';
import '../../../auth/data/models/admin_response_models.dart';

/// Página para que el administrador vea todos los tickets del sistema
class AdminAllTicketsPage extends ConsumerStatefulWidget {
  static const String name = 'AdminAllTicketsPage';

  const AdminAllTicketsPage({super.key});

  @override
  AdminAllTicketsPageState createState() => AdminAllTicketsPageState();
}

class AdminAllTicketsPageState extends ConsumerState<AdminAllTicketsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 AdminAllTicketsPageState.initState() - Loading data');
      ref.read(usersProvider.notifier).loadUsers();
      ref.read(clientsProvider.notifier).getClients();
      ref.read(reservationProvider.notifier).getReservations();
      // Refresh tickets explicitly
      ref.refresh(ticketsProvider);
      print('🎫 AdminAllTicketsPageState.initState() - Refreshed ticketsProvider');
      // Note: ticketEstadosProvider, ticketImportanciasProvider, ticketUrgenciasProvider are FutureProviders
      // They load automatically when watched, no need to call load() manually
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
    final estadosAsync = ref.watch(ticketEstadosProvider);
    final importanciasAsync = ref.watch(ticketImportanciasProvider);
    final urgenciasAsync = ref.watch(ticketUrgenciasProvider);
    final estados =
        estadosAsync.maybeWhen(data: (items) => items, orElse: () => const <lookup.State>[]);
    final importancias =
        importanciasAsync.maybeWhen(data: (items) => items, orElse: () => const <lookup.State>[]);
    final urgencias =
        urgenciasAsync.maybeWhen(data: (items) => items, orElse: () => const <lookup.State>[]);
    final servicesState = ref.watch(servicesProvider);
    final clientsState = ref.watch(clientsProvider);
    final reservationsById = ref.watch(reservationsByIdProvider);
    final clientsById = <String, Client>{
      for (final client in clientsState.clients) client.id.toString(): client,
    };
    final filteredTickets = _filterTickets(
      ticketsState.tickets,
      filtersState,
      clientsById,
      reservationsById,
    );
    final stats = _buildStats(ticketsState.tickets);

    if (filtersState.isSearching && !_searchFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Tickets',
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
        else ...[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              filtersNotifier.startSearch();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchFocusNode.requestFocus();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
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
            filterStatus: filtersState.filterStatus,
            onFilterChanged: filtersNotifier.setFilterStatus,
          ),

          const SizedBox(height: 16),

          // Lista de tickets
          Expanded(
            child: ticketsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : AdminTicketsList(
                    tickets: filteredTickets,
                    ticketStates: estados,
                    ticketImportances: importancias,
                    ticketUrgencies: urgencias,
                    services: servicesState.services,
                    // operators: operatorsState.operators,
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
      final stateId = ticket.estado.id;
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

  List<Ticket> _filterTickets(
    List<Ticket> tickets,
    TicketsFiltersState filtersState,
    Map<String, Client> clientsById,
    Map<String, Reservation> reservationsById,
  ) {
    return tickets.where((ticket) {
      final stateId = ticket.estado.id;
      final matchesStatus = switch (filtersState.filterStatus) {
        'pending' => stateId == 1,
        'assigned' => stateId == 2,
        'inProgress' => stateId == 3,
        'completed' => stateId == 4 || stateId == 5,
        _ => true,
      };

      final matchesType = true;

      final matchesState =
          filtersState.stateId == null || ticket.estado.id == filtersState.stateId;
      final matchesImportance = filtersState.importanceId == null ||
          ticket.importancia.id == filtersState.importanceId;
      final matchesUrgency = filtersState.urgencyId == null ||
          ticket.urgencia.id == filtersState.urgencyId;
      final matchesService = filtersState.serviceId == null ||
          ticket.idServicio == filtersState.serviceId;

      final range = filtersState.dateRange;
      final ticketDate = ticket.desde ?? ticket.createdAt;
      final matchesDate = range == null || ticketDate == null
          ? true
          : !(ticketDate.isBefore(range.start) ||
              ticketDate.isAfter(range.end));

      final query = filtersState.searchQuery.trim().toLowerCase();
      final clientName = _resolveClientName(ticket, clientsById, reservationsById);
      final matchesSearch =
          query.isEmpty ||
          ticket.id.toString().contains(query) ||
          clientName.toLowerCase().contains(query) ||
          ticket.nombre.toLowerCase().contains(query) ||
          ticket.description.toLowerCase().contains(query);

      return matchesStatus &&
          matchesType &&
          matchesSearch &&
          matchesState &&
          matchesImportance &&
          matchesUrgency &&
          matchesService &&
          matchesDate;
    }).toList()
      ..sort((a, b) {
        final aDate = a.desde ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.desde ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
  }

  String _resolveClientName(
    Ticket ticket,
    Map<String, Client> clientsById,
    Map<String, Reservation> reservationsById,
  ) {
    final reservation = reservationsById[ticket.idReserva];
    if (reservation != null) {
      final name = reservation.name.trim();
      if (name.isNotEmpty) return name;
      if (reservation.email.trim().isNotEmpty) return reservation.email.trim();
    }
    final userId = ticket.idUser?.trim() ?? '';
    if (userId.isEmpty) return 'Sin nombre';
    final client = clientsById[userId];
    if (client != null) {
      final name = client.name.trim();
      if (name.isNotEmpty) return name;
      if (client.email.trim().isNotEmpty) return client.email.trim();
    }
    return 'Cliente no encontrado';
  }

  void _showFilterDialog(BuildContext context) {
    final filtersNotifier = ref.read(ticketsFiltersProvider.notifier);
    final filtersState = ref.read(ticketsFiltersProvider);
    final estadosCrudState = ref.read(ticketEstadosCrudProvider);
    final importanciasCrudState = ref.read(ticketImportanciasCrudProvider);
    final urgenciasCrudState = ref.read(ticketUrgenciasCrudProvider);
    final estados = estadosCrudState.items;
    final importancias = importanciasCrudState.items;
    final urgencias = urgenciasCrudState.items;
    final servicesState = ref.read(servicesProvider);
    showDialog(
      context: context,
      builder: (context) {
        DateTimeRange? selectedRange = filtersState.dateRange;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Filtros Avanzados'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: filtersState.filterType,
                    decoration: const InputDecoration(labelText: 'Tipo de Ticket'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todos')),
                      DropdownMenuItem(value: 'reservation', child: Text('Reservas')),
                      DropdownMenuItem(value: 'purchase', child: Text('Compras')),
                      DropdownMenuItem(value: 'order', child: Text('Pedidos')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        filtersNotifier.setFilterType(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    value: filtersState.stateId,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ...estados.map(
                        (state) => DropdownMenuItem(
                          value: state.id,
                          child: Text(state.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      filtersNotifier.setStateFilter(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    value: filtersState.importanceId,
                    decoration: const InputDecoration(labelText: 'Importancia'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      ...importancias.map(
                        (state) => DropdownMenuItem(
                          value: state.id,
                          child: Text(state.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      filtersNotifier.setImportanceFilter(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    value: filtersState.urgencyId,
                    decoration: const InputDecoration(labelText: 'Urgencia'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      ...urgencias.map(
                        (state) => DropdownMenuItem(
                          value: state.id,
                          child: Text(state.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      filtersNotifier.setUrgencyFilter(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    value: filtersState.serviceId,
                    decoration: const InputDecoration(labelText: 'Servicio'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ...servicesState.services.map(
                        (service) => DropdownMenuItem(
                          value: int.tryParse(service.id),
                          child: Text(service.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      filtersNotifier.setServiceFilter(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Rango de fechas'),
                    subtitle: Text(
                      selectedRange == null
                          ? 'Todas'
                          : '${selectedRange!.start.toString().substring(0, 10)} - ${selectedRange!.end.toString().substring(0, 10)}',
                    ),
                    trailing: const Icon(Icons.date_range),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDateRange: selectedRange,
                      );
                      if (picked != null) {
                        setState(() => selectedRange = picked);
                        filtersNotifier.setDateRange(picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
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
          const SizedBox(width: 12),
          Expanded(
            child: StatisticCard(
              title: 'En Progreso',
              count: inProgressCount.toString(),
              icon: Icons.engineering,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
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
  final List<lookup.State> ticketStates;
  final List<lookup.State> ticketImportances;
  final List<lookup.State> ticketUrgencies;
  final List<Services> services;

  const AdminTicketsList({
    super.key,
    required this.tickets,
    required this.ticketStates,
    required this.ticketImportances,
    required this.ticketUrgencies,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const Center(child: Text('No hay tickets'));
    }
    final unassigned = tickets
        .where((ticket) => ticket.idUser == null || ticket.idUser!.isEmpty)
        .toList();
    final assigned = tickets
        .where((ticket) => ticket.idUser != null && ticket.idUser!.isNotEmpty)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'Sin asignar', count: unassigned.length),
        ...unassigned.map(
          (ticket) => AdminTicketCard(
            ticket: ticket,
            ticketStates: ticketStates,
            ticketImportances: ticketImportances,
            ticketUrgencies: ticketUrgencies,
            services: services,
          ),
        ),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Asignados', count: assigned.length),
        ...assigned.map(
          (ticket) => AdminTicketCard(
            ticket: ticket,
            ticketStates: ticketStates,
            ticketImportances: ticketImportances,
            ticketUrgencies: ticketUrgencies,
            services: services,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de ticket para vista de administrador
class AdminTicketCard extends ConsumerStatefulWidget {
  final Ticket ticket;
  final List<lookup.State> ticketStates;
  final List<lookup.State> ticketImportances;
  final List<lookup.State> ticketUrgencies;
  final List<Services> services;

  const AdminTicketCard({
    super.key,
    required this.ticket,
    required this.ticketStates,
    required this.ticketImportances,
    required this.ticketUrgencies,
    required this.services,
  });

  @override
  ConsumerState<AdminTicketCard> createState() => _AdminTicketCardState();
}

class _AdminTicketCardState extends ConsumerState<AdminTicketCard> {
  bool get _hasAssignment =>
      widget.ticket.idUser?.trim().isNotEmpty == true;

  String? _resolveOperatorName(
    Map<String, AdminUserModel> usersById,
  ) {
    final assignedId = widget.ticket.idUser;
    if (assignedId == null || assignedId.isEmpty) return null;

    final user = usersById[assignedId];
    if (user == null) return 'Operario no encontrado';
    final name = user.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return user.email;
  }

  Future<void> _showAssignOperatorDialog(BuildContext context) async {
    ref.read(usersProvider.notifier).loadUsers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final usersState = ref.watch(usersProvider);
            final operarios = ref.watch(operariosProvider);

            if (usersState.isLoading && usersState.users.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (usersState.errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  usersState.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            if (operarios.isEmpty) {
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
                        itemCount: operarios.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final operator = operarios[index];
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
                                    ticket: widget.ticket,
                                    operatorId: operator.id,
                                    operatorName: operatorName,
                                  );
                              if (!context.mounted) return;
                              if (ok) {
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

  String _resolveClientName(
    Map<String, Client> clientsById,
    Map<String, Reservation> reservationsById,
  ) {
    final reservation = reservationsById[widget.ticket.idReserva];
    if (reservation != null) {
      final name = reservation.name.trim();
      if (name.isNotEmpty) return name;
      if (reservation.email.trim().isNotEmpty) return reservation.email.trim();
    }
    final userId = widget.ticket.idUser?.trim() ?? '';
    if (userId.isEmpty) return 'Sin nombre';
    final client = clientsById[userId];
    if (client != null) {
      final name = client.name.trim();
      if (name.isNotEmpty) return name;
      if (client.email.trim().isNotEmpty) return client.email.trim();
    }
    return 'Cliente no encontrado';
  }

  @override
  Widget build(BuildContext context) {
    final states = widget.ticketStates;
    final hasStates = states.isNotEmpty;
    final hasImportances = widget.ticketImportances.isNotEmpty;
    final hasUrgencies = widget.ticketUrgencies.isNotEmpty;
    final currentStateId = widget.ticket.estado.id;
    final currentImportanceId = widget.ticket.importancia.id;
    final currentUrgencyId = widget.ticket.urgencia.id;
    final selectedStateName = states.isEmpty
        ? 'Estado'
        : states
            .firstWhere(
              (state) => state.id == currentStateId,
              orElse: () => states.first,
            )
            .name;
    final serviceName = widget.services
        .firstWhere(
          (service) => int.tryParse(service.id) == widget.ticket.idServicio,
          orElse: () => widget.services.isNotEmpty
              ? widget.services.first
              : Services(
                  id: '',
                  name: '',
                  description: '',
                  minPrice: 0,
                  maxPrice: 0,
                  durationMinutes: 0,
                  requiresReservation: true,
                  isActive: true,
                  images: const [],
                ),
        )
        .name;
    final operarios = ref.watch(operariosProvider);
    final operariosById = {
      for (final operario in operarios) operario.id: operario,
    };
    final resolvedOperatorName = _resolveOperatorName(operariosById);
    final assignmentLabel = resolvedOperatorName != null
        ? 'Asignado a: $resolvedOperatorName'
        : 'Sin asignar';
    final clientsState = ref.watch(clientsProvider);
    final reservationsById = ref.watch(reservationsByIdProvider);
    final clientsById = <String, Client>{
      for (final client in clientsState.clients) client.id.toString(): client,
    };
    final clientName = _resolveClientName(clientsById, reservationsById);
    final canAssign = !_hasAssignment;
    final canEdit = currentStateId != 4 && currentStateId != 5;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusBadge(
                          label: selectedStateName,
                          color: _getStatusColor(currentStateId),
                        ),
                        TypeBadge(
                          label: serviceName.isNotEmpty ? serviceName : 'Servicio',
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Ticket #${widget.ticket.id}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: Text(
                      'Estado del ticket:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int>(
                      value: hasStates ? currentStateId : null,
                      isExpanded: true,
                      items: states
                          .map(
                            (state) => DropdownMenuItem(
                              value: state.id,
                              child: Text(state.name),
                            ),
                          )
                          .toList(),
                      onChanged: !hasStates
                          ? null
                          : (value) {
                              if (value == null) return;
                              final stateName = states
                                  .firstWhere(
                                    (s) => s.id == value,
                                    orElse: () => states.first,
                                  )
                                  .name;
                              ref
                                  .read(ticketsProvider.notifier)
                                  .updateTicketPriority(
                                    ticket: widget.ticket,
                                    stateId: value,
                                    stateName: stateName,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.priority_high, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: Text(
                      'Importancia:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int>(
                      value: hasImportances ? currentImportanceId : null,
                      isExpanded: true,
                      items: widget.ticketImportances
                          .map(
                            (state) => DropdownMenuItem(
                              value: state.id,
                              child: Text(state.name),
                            ),
                          )
                          .toList(),
                      onChanged: !hasImportances
                          ? null
                          : (value) {
                              if (value == null) return;
                              final importanceName = widget.ticketImportances
                                  .firstWhere(
                                    (s) => s.id == value,
                                    orElse: () => widget.ticketImportances.first,
                                  )
                                  .name;
                              ref
                                  .read(ticketsProvider.notifier)
                                  .updateTicketPriority(
                                    ticket: widget.ticket,
                                    importanceId: value,
                                    importanceName: importanceName,
                                  );
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: Text(
                      'Urgencia:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int>(
                      value: hasUrgencies ? currentUrgencyId : null,
                      isExpanded: true,
                      items: widget.ticketUrgencies
                          .map(
                            (state) => DropdownMenuItem(
                              value: state.id,
                              child: Text(state.name),
                            ),
                          )
                          .toList(),
                      onChanged: !hasUrgencies
                          ? null
                          : (value) {
                              if (value == null) return;
                              final urgencyName = widget.ticketUrgencies
                                  .firstWhere(
                                    (s) => s.id == value,
                                    orElse: () => widget.ticketUrgencies.first,
                                  )
                                  .name;
                              ref
                                  .read(ticketsProvider.notifier)
                                  .updateTicketPriority(
                                    ticket: widget.ticket,
                                    urgencyId: value,
                                    urgencyName: urgencyName,
                                  );
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.ticket.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Cliente: ${clientName.isNotEmpty ? clientName : 'Sin nombre'}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.engineering, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      assignmentLabel,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  if (canAssign)
                    TextButton.icon(
                      onPressed: () => _showAssignOperatorDialog(context),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Asignar'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3498db),
                      ),
                    ),
                  // else
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 12,
                    //     vertical: 6,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: Colors.green.shade50,
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: Text(
                    //     resolvedOperatorName != null
                    //         ? 'Asignado a: $resolvedOperatorName'
                    //         : 'Ticket asignado',
                    //     style: const TextStyle(
                    //       fontSize: 13,
                    //       color: Colors.green,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    // ),
                  TextButton.icon(
                    onPressed: () {
                      context.push('/admin-ticket/${widget.ticket.id}');
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ver Detalle'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3498db),
                    ),
                  ),
                  if (canEdit)
                    TextButton.icon(
                      onPressed: () {
                        context.push('/admin-ticket/${widget.ticket.id}/edit');
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar'),
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
