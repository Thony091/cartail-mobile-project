import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/data/models/admin_response_models.dart';
import 'package:portafolio_project/features/auth/presentation/providers/admin_auth_provider.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/auth/presentation/providers/users_provider.dart';
import 'package:portafolio_project/features/client/presentation/providers/clients_provider.dart';
import 'package:portafolio_project/features/reservation/domain/entities/reservation.dart';
import 'package:portafolio_project/features/reservation/presentation/providers/reservation_derived_providers.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../state/presentation/providers/states_provider.dart';
import 'widgets/ticket_widgets.dart';
import '../providers/operator_ticket_progress_provider.dart';
import '../providers/tickets_provider.dart';
import '../../domain/entities/ticket.dart';
import '../../../../presentation/presentation_container.dart';
import '../providers/operator_tickets_derived_providers.dart';

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
      ref.read(clientsProvider.notifier).getClients();
      ref.read(reservationProvider.notifier).getReservations();
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
            icon: const Icon(
              Icons.close, 
              color: Colors.white
            ),
            onPressed: () {
              filtersNotifier.stopSearch();
              _searchController.clear();
              _searchFocusNode.unfocus();
            },
          )
        else
          IconButton(
            icon: const Icon(
              Icons.search, 
              color: Colors.white
            ),
            onPressed: () {
              filtersNotifier.startSearch();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchFocusNode.requestFocus();
              });
            },
          ),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withValues(alpha: .2),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: GestureDetector(
          onTap:() => _searchFocusNode.unfocus(),
          child: Column(
            children: [
              // Resumen de tickets
              const OperatorSummarySection(),

              const SizedBox(height: 16),

              // Filtros
              const OperatorFiltersSection(),

              const SizedBox(height: 16),

              // Lista de tickets asignados
              Expanded(
                child: ticketsState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator()
                    )
                  : const OperatorTicketsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sección de resumen para operarios
class OperatorSummarySection extends ConsumerWidget {
  const OperatorSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(operatorTicketStatsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SummaryCard(
              title: 'Pendientes',
              count: stats.pending.toString(),
              icon: Icons.pending,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'En Progreso',
              count: stats.inProgress.toString(),
              icon: Icons.work,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'Completados Hoy',
              count: stats.completed.toString(),
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
class OperatorFiltersSection extends ConsumerWidget {
  const OperatorFiltersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtersState = ref.watch(ticketsFiltersProvider);
    final filtersNotifier = ref.read(ticketsFiltersProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: 'Todos',
            selected: filtersState.filterStatus == 'all',
            onTap: () => filtersNotifier.setFilterStatus('all'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: 'Pendientes',
            selected: filtersState.filterStatus == 'pending',
            onTap: () => filtersNotifier.setFilterStatus('pending'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: 'En Progreso',
            selected: filtersState.filterStatus == 'inProgress',
            onTap: () => filtersNotifier.setFilterStatus('inProgress'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: 'Completados',
            selected: filtersState.filterStatus == 'completed',
            onTap: () => filtersNotifier.setFilterStatus('completed'),
          ),
        ],
      ),
    );
  }
}

/// Lista de tickets asignados al operario
class OperatorTicketsList extends ConsumerWidget {
  const OperatorTicketsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(filteredOperatorTicketsProvider);

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
        );
      },
    );
  }
}

/// Tarjeta de ticket para vista de operario
class OperatorTicketCard extends ConsumerStatefulWidget {
  final int index;
  final Ticket ticket;

  const OperatorTicketCard({
    super.key,
    required this.index,
    required this.ticket,
  });

  @override
  ConsumerState<OperatorTicketCard> createState() => _OperatorTicketCardState();
}

class _OperatorTicketCardState extends ConsumerState<OperatorTicketCard> {
  String? _resolveOperatorName(Map<String, AdminUserModel> operatorsById) {
    final assignedId = widget.ticket.idUser ?? '';
    if (assignedId.isEmpty) return null;

    final operator = operatorsById[assignedId];
    if (operator == null) return 'Operario no encontrado';

    final trimmed = operator.name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return operator.email;
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
    final operatorName = ref.watch(currentOperatorNameProvider);
    final reservationsState = ref.watch(reservationProvider);
    final ticket = widget.ticket;
    Reservation? reservation;
    for (final r in reservationsState.reservations) {
      if (r.id.toString() == ticket.idReserva) {
        reservation = r;
        break;
      }
    }
    final usersList = ref.watch(usersProvider);
    AdminUserModel? assignedUser;
    final reservationClientId = reservation?.clientId?.toString();
    if (reservationClientId != null && reservationClientId.isNotEmpty) {
      for (final user in usersList.users) {
        if (user.id.toString() == reservationClientId) {
          assignedUser = user;
          break;
        }
      }
    }
    final currentStateId = widget.ticket.estado.id;
    final states = ref.watch(statesProvider);
    final hasStates = states.isNotEmpty;
    final selectedStateName = hasStates
        ? states
            .firstWhere(
              (state) => state.id == currentStateId,
              orElse: () => states.first,
            )
            .name
        : 'Estado';
    final isPriority = widget.index % 3 == 0;
    final operarios = ref.watch(operariosProvider);
    final operariosById = {
      for (final operario in operarios) operario.id: operario,
    };
    final resolvedOperatorName = _resolveOperatorName(operariosById);
    final displayOperatorName = _normalizeName(
      resolvedOperatorName,
      fallback: operatorName,
    );
    final clientName = _resolveClientNameFromReservation(
      reservation: reservation,
      user: assignedUser,
    );

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
          operatorName,
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
                    color: _getStatusColor(currentStateId),
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
                  const Icon(
                    Icons.flag_outlined, 
                    size: 16, 
                    color: Colors.grey
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Estado:',
                    style: TextStyle(
                      fontSize: 13, 
                      color: Colors.grey
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int>(
                      value: hasStates ? currentStateId : null,
                      isExpanded: true,
                      items: hasStates
                          ? states
                              .map(
                                (state) => DropdownMenuItem(
                                  value: state.id,
                                  child: Text(state.name),
                                ),
                              )
                              .toList()
                          : const [],
                      onChanged: !hasStates
                          ? null
                          : (value) {
                              if (value == null) return;
                              final stateName = states.firstWhere(
                                (s) => s.id == value,
                                orElse: () => states.first,
                              ).name;
                              ref.read(ticketsProvider.notifier).updateTicketStatus(
                                ticket: widget.ticket,
                                stateId: value,
                                stateName: stateName,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Estado actualizado a $stateName',
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
                widget.ticket.nombre,
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
                      'Asignado: $operatorName',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (_getReservation(ref, widget.ticket) != null) ...[
                const SizedBox(height: 4),
                _buildReservationInfo(ref),
              ],
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

  String _resolveClientNameFromReservation({
    required Reservation? reservation,
    required AdminUserModel? user,
  }) {
    if (user != null) {
      final name = user.name?.trim();
      if (name != null && name.isNotEmpty) return name;
      return user.email;
    }
    if (reservation != null) {
      if (reservation.name.trim().isNotEmpty) return reservation.name.trim();
      if (reservation.email.trim().isNotEmpty) return reservation.email.trim();
    }
    return 'Sin nombre';
  }

  String? _getReservationId(Ticket ticket) {
    final reservationId = ticket.idReserva.trim();
    return reservationId.isEmpty ? null : reservationId;
  }

  Reservation? _getReservation(WidgetRef ref, Ticket ticket) {
    final reservationId = _getReservationId(ticket);
    if (reservationId == null || reservationId.isEmpty) return null;

    final reservationsById = ref.watch(reservationsByIdProvider);
    return reservationsById[reservationId];
  }

  Widget _buildReservationInfo(WidgetRef ref) {
    final reservation = _getReservation(ref, widget.ticket);
    if (reservation == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              Text(
                'Vehículo: ${reservation.vehiclePlate.isNotEmpty ? reservation.vehiclePlate : 'N/A'}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          if (reservation.serviceName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.build, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Servicio: ${reservation.serviceName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],
          if (reservation.reservationDate.isNotEmpty ||
              reservation.reservationTime.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                Text(
                  '${reservation.reservationDate} ${reservation.reservationTime}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildReservationDetails(WidgetRef ref) {
    final reservation = _getReservation(ref, widget.ticket);
    if (reservation == null) return [];

    return [
      if (reservation.vehiclePlate.isNotEmpty)
        DetailRowWidget(label: 'Patente', value: reservation.vehiclePlate),
      if (reservation.serviceName.isNotEmpty)
        DetailRowWidget(label: 'Servicio', value: reservation.serviceName),
      if (reservation.reservationDate.isNotEmpty)
        DetailRowWidget(label: 'Fecha', value: reservation.reservationDate),
      if (reservation.reservationTime.isNotEmpty)
        DetailRowWidget(label: 'Hora inicio', value: reservation.reservationTime),
      if (reservation.endTimeEstimated.isNotEmpty)
        DetailRowWidget(
          label: 'Hora fin estimada',
          value: reservation.endTimeEstimated,
        ),
      if (reservation.customerNotes.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Text(
          'Notas del Cliente',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Text(
            reservation.customerNotes,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),
      ],
      if (reservation.mechanicNotes.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Text(
          'Notas del Mecánico',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Text(
            reservation.mechanicNotes,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    ];
  }

  Future<void> _showTicketDetailSheet(
    BuildContext context,
    String operatorName,
    String clientName,
  ) async {
    final states = ref.read(statesProvider);
    final operatorId = ref.read(currentOperatorIdProvider);
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
            final progressState = ref.watch(operatorTicketProgressProvider(widget.ticket));
            final progressNotifier = ref.read(operatorTicketProgressProvider(widget.ticket).notifier);
            final stateName = states.isNotEmpty
                ? states
                    .firstWhere(
                      (state) => state.id == progressState.stateId,
                      orElse: () => states.first,
                    )
                    .name
                : 'Estado';
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
                            widget.ticket.nombre,
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
                    DetailRowWidget(label: 'Cliente', value: clientName),
                    DetailRowWidget(label: 'Operario', value: operatorName),
                    DetailRowWidget(label: 'Estado actual', value: stateName),
                    if (_getReservation(ref, widget.ticket) != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Información de Reserva',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildReservationDetails(ref),
                    ],
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
                      value: states.isNotEmpty ? progressState.stateId : null,
                      decoration: const InputDecoration(
                        labelText: 'Cambiar estado',
                        border: OutlineInputBorder(),
                      ),
                      items: states.isNotEmpty
                          ? states
                              .map(
                                (state) => DropdownMenuItem(
                                  value: state.id,
                                  child: Text(state.name),
                                ),
                              )
                              .toList()
                          : const [],
                      onChanged: states.isNotEmpty
                          ? (value) {
                              if (value == null) return;
                              progressNotifier.changeState(value);
                            }
                          : null,
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
                                    operatorId: operatorId,
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

class DetailRowWidget extends StatelessWidget {
  final String label;
  final String value;
  const DetailRowWidget({
    super.key, 
    required this.label, 
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}
