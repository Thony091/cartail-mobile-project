import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../auth/data/models/admin_response_models.dart';
import '../../../auth/presentation/providers/users_provider.dart';
import '../../../client/domain/entities/client.dart';
import '../../../client/presentation/providers/clients_provider.dart';
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
        title: 'Detalle de Ticket',
        body: Center(child: Text('Ticket no encontrado')),
      );
    }

    final operarios = ref.watch(operariosProvider);
    final operariosById = {
      for (final operario in operarios) operario.id: operario,
    };
    final operario = operariosById[ticket.assignedToId ?? ''];
    final operarioName = _resolveOperatorName(ticket, operario);
    final clientsState = ref.watch(clientsProvider);
    final clientsById = <String, Client>{
      for (final client in clientsState.clients) client.id.toString(): client,
    };
    final clientName = _resolveClientName(ticket, clientsById);
    final estados = ref.watch(ticketEstadosProvider);
    final importancias = ref.watch(ticketImportanciasProvider);
    final urgencias = ref.watch(ticketUrgenciasProvider);
    final estado = _lookupName(estados, ticket.stateId);
    final importancia = _lookupName(importancias, ticket.importanceId);
    final urgencia = _lookupName(urgencias, ticket.urgencyId);
    final serviceName = _resolveServiceName(
      ref.watch(servicesProvider).services,
      ticket.serviceId,
    );

    return ModernScaffoldWithDrawer(
      title: 'Detalle de Ticket',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: ticket.title,
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
              _InfoRow(label: 'Desde', value: _formatDate(ticket.startDate)),
              _InfoRow(label: 'Hasta', value: _formatDate(ticket.endDate)),
            ],
          ),
        ],
      ),
    );
  }

  String _resolveOperatorName(Ticket ticket, AdminUserModel? operario) {
    final explicit = ticket.assignedToName?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (operario == null) {
      return ticket.assignedToId?.isNotEmpty == true
          ? 'Operario no encontrado'
          : 'Sin asignar';
    }
    final name = operario.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return operario.email;
  }

  String _resolveClientName(Ticket ticket, Map<String, Client> clientsById) {
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
    return 'Cliente no encontrado';
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

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
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
