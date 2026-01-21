import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'widgets/ticket_widgets.dart';

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
    // TODO: Implementar provider de tickets cuando esté disponible
    // final ticketsState = ref.watch(ticketsProvider);

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
          const TicketStatisticsSection(),

          const SizedBox(height: 16),

          // Filtros rápidos
          QuickFiltersSection(
            filterStatus: _filterStatus,
            onFilterChanged: (value) => setState(() => _filterStatus = value),
          ),

          const SizedBox(height: 16),

          // Lista de tickets
          const Expanded(child: AdminTicketsList()),
        ],
      ),
    );
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

/// Sección de estadísticas de tickets
class TicketStatisticsSection extends StatelessWidget {
  const TicketStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Expanded(
            child: StatisticCard(
              title: 'Pendientes',
              count: '12',
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: StatisticCard(
              title: 'En Progreso',
              count: '8',
              icon: Icons.engineering,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: StatisticCard(
              title: 'Completados',
              count: '45',
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
  const AdminTicketsList({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Reemplazar con datos reales del provider
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return AdminTicketCard(index: index);
      },
    );
  }
}

/// Tarjeta de ticket para vista de administrador
class AdminTicketCard extends StatelessWidget {
  final int index;

  const AdminTicketCard({super.key, required this.index});

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.purple;
      case 3:
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
        return 'Asignado';
      case 2:
        return 'En Progreso';
      case 3:
        return 'Completado';
      default:
        return 'Desconocido';
    }
  }

  String _getTypeLabel(int type) {
    switch (type) {
      case 0:
        return 'Reserva';
      case 1:
        return 'Compra';
      case 2:
        return 'Pedido';
      default:
        return 'Otro';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    label: _getStatusLabel(index % 4),
                    color: _getStatusColor(index % 4),
                  ),
                  const SizedBox(width: 8),
                  TypeBadge(label: _getTypeLabel(index % 3)),
                  const Spacer(),
                  Text(
                    'Ticket #${1000 + index}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Reserva de Servicio de Detailing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Cliente: Juan Pérez',
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
                    index % 2 == 0 ? 'Asignado a: María García' : 'Sin asignar',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (index % 2 != 0)
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Navegar a asignar operario
                        // context.push('/admin-assign-ticket/$ticketId');
                      },
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
