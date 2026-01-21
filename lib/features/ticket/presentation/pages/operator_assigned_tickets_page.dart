import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'widgets/ticket_widgets.dart';

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
    // TODO: Implementar provider de tickets cuando esté disponible
    // final myTicketsState = ref.watch(myAssignedTicketsProvider);

    return ModernScaffoldWithDrawer(
      title: 'Mis Tickets Asignados',
      body: Column(
        children: [
          // Resumen de tickets
          const OperatorSummarySection(),

          const SizedBox(height: 16),

          // Filtros
          OperatorFiltersSection(
            filterStatus: _filterStatus,
            onFilterChanged: (value) => setState(() => _filterStatus = value),
          ),

          const SizedBox(height: 16),

          // Lista de tickets asignados
          const Expanded(child: OperatorTicketsList()),
        ],
      ),
    );
  }
}

/// Sección de resumen para operarios
class OperatorSummarySection extends StatelessWidget {
  const OperatorSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Expanded(
            child: SummaryCard(
              title: 'Pendientes',
              count: '3',
              icon: Icons.pending,
              color: Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'En Progreso',
              count: '5',
              icon: Icons.work,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'Completados Hoy',
              count: '2',
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
  const OperatorTicketsList({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Reemplazar con datos reales del provider
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return OperatorTicketCard(index: index);
      },
    );
  }
}

/// Tarjeta de ticket para vista de operario
class OperatorTicketCard extends StatelessWidget {
  final int index;

  const OperatorTicketCard({super.key, required this.index});

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.purple;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 0:
        return 'Pendiente';
      case 1:
        return 'En Progreso';
      case 2:
        return 'Completado';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPriority = index % 3 == 0;

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
                    label: _getStatusLabel(index % 3),
                    color: _getStatusColor(index % 3),
                  ),
                  const Spacer(),
                  Text(
                    'Ticket #${2000 + index}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Servicio de Detailing Premium',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Cliente: Ana Martínez',
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
                    'Asignado hace ${index + 1} horas',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (index % 3 == 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Iniciar trabajo
                      },
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Iniciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (index % 3 == 2)
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Completar trabajo
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Completar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498db),
                        foregroundColor: Colors.white,
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
