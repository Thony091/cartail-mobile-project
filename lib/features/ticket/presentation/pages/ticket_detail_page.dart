import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../auth/data/models/admin_response_models.dart';
import '../../../auth/presentation/providers/users_provider.dart';
import '../../../client/domain/entities/client.dart';
import '../../../client/presentation/providers/clients_provider.dart';
import '../../../reservation/domain/entities/reservation.dart';
import '../../../reservation/presentation/providers/reservation_derived_providers.dart';
import '../../../reservation/presentation/providers/reservation_provider.dart';
import '../../../services/domain/entities/services.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../shared/domain/entities/state.dart' as lookup;
import '../../domain/entities/ticket.dart';
import '../providers/ticket_lookup_crud_providers.dart';
import '../providers/tickets_provider.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  static const String name = 'TicketDetailPage';

  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
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
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);
    final ticket = ticketsState.tickets.cast<Ticket?>().firstWhere(
          (t) => t?.id.toString() == widget.ticketId,
          orElse: () => null,
        );

    if (ticket == null) {
      return const ModernScaffoldWithDrawer(
        title: 'Detalle de Ticket',
        body: Center(child: Text('Ticket no encontrado')),
      );
    }

    final operarios = ref.watch(operariosProvider);
    final operariosById = {
      for (final operario in operarios) operario.id: operario,
    };
    final operario = operariosById[ticket.idUser ?? ''];
    final operarioName = _resolveOperatorName(ticket, operario);
    final clientsState = ref.watch(clientsProvider);
    final reservationsById = ref.watch(reservationsByIdProvider);
    final clientsById = <String, Client>{
      for (final client in clientsState.clients) client.id.toString(): client,
    };
    final clientName = _resolveClientName(ticket, clientsById, reservationsById);
    final estados = ref.watch(ticketEstadosProvider);
    final importancias = ref.watch(ticketImportanciasProvider);
    final urgencias = ref.watch(ticketUrgenciasProvider);
    final estado = ticket.estado.nombre.isNotEmpty
        ? ticket.estado.nombre
        : _lookupName(estados, ticket.estado.id);
    final importancia = ticket.importancia.nombre.isNotEmpty
        ? ticket.importancia.nombre
        : _lookupName(importancias, ticket.importancia.id);
    final urgencia = ticket.urgencia.nombre.isNotEmpty
        ? ticket.urgencia.nombre
        : _lookupName(urgencias, ticket.urgencia.id);
    final serviceName = _resolveServiceName(
      ref.watch(servicesProvider).services,
      ticket.idServicio,
    );

    return ModernScaffoldWithDrawer(
      title: 'Detalle de Ticket',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: ticket.nombre,
            children: [
              _InfoRow(label: 'Cliente', value: clientName),
              _InfoRow(label: 'Descripción', value: ticket.description),
            ],
          ),
          _SectionCard(
            title: 'Información general',
            children: [
              _InfoRow(label: 'Operario', value: operarioName),
              _InfoRow(label: 'Estado', value: estado ?? 'Sin estado'),
              _InfoRow(
                label: 'Importancia',
                value: importancia ?? 'Sin importancia',
              ),
              _InfoRow(label: 'Urgencia', value: urgencia ?? 'Sin urgencia'),
              _InfoRow(label: 'Servicio', value: serviceName),
              _InfoRow(label: 'Desde', value: _formatDate(ticket.desde)),
              _InfoRow(label: 'Hasta', value: _formatDate(ticket.hasta)),
            ],
          ),
        ],
      ),
    );
  }

  String _resolveOperatorName(Ticket ticket, AdminUserModel? operario) {
    if (operario == null) {
      return ticket.idUser?.isNotEmpty == true
          ? 'Operario no encontrado'
          : 'Sin asignar';
    }
    final name = operario.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return operario.email;
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

  String? _lookupName(List<lookup.State> items, int? id) {
    if (id == null) return null;
    for (final item in items) {
      if (item.id == id) {
        return item.name;
      }
    }
    return null;
  }

  String _resolveServiceName(List<Services> services, int? serviceId) {
    if (services.isEmpty || serviceId == null) return 'Sin servicio';
    return services
        .firstWhere(
          (service) => int.tryParse(service.id) == serviceId,
          orElse: () => services.first,
        )
        .name;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return date.toString();
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

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
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
