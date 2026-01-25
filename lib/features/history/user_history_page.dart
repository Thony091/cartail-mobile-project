import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../user/domain/entities/user_role.dart';
import '../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../ticket/presentation/pages/widgets/ticket_widgets.dart';

/// Página de historial para usuarios autenticados
/// Muestra diferentes vistas según el rol del usuario
class UserHistoryPage extends ConsumerStatefulWidget {
  static const String name = 'UserHistoryPage';

  const UserHistoryPage({super.key});

  @override
  UserHistoryPageState createState() => UserHistoryPageState();
}

class UserHistoryPageState extends ConsumerState<UserHistoryPage> {
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(betterAuthProvider);
    final userRole = authState.session!.user.role;

    return ModernScaffoldWithDrawer(
      title: _getTitleForRole(userRole),
      body: Column(
        children: [
          // Filtros
          HistoryFiltersSection(
            filterType: _filterType,
            onFilterChanged: (value) => setState(() => _filterType = value),
          ),

          const SizedBox(height: 16),

          // Lista de historial
          Expanded(child: HistoryList(userRole: userRole)),
        ],
      ),
    );
  }

  String _getTitleForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Historial Completo';
      case UserRole.operator:
        return 'Mi Historial de Trabajo';
      case UserRole.user:
        return 'Mi Historial';
      default:
        return 'Historial';
    }
  }
}

/// Sección de filtros para historial
class HistoryFiltersSection extends StatelessWidget {
  final String filterType;
  final ValueChanged<String> onFilterChanged;

  const HistoryFiltersSection({
    super.key,
    required this.filterType,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          FilterChip(
            label: 'Todos',
            selected: filterType == 'all',
            onTap: () => onFilterChanged('all'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: 'Reservas',
            selected: filterType == 'reservation',
            onTap: () => onFilterChanged('reservation'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: 'Compras',
            selected: filterType == 'purchase',
            onTap: () => onFilterChanged('purchase'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: 'Pedidos',
            selected: filterType == 'order',
            onTap: () => onFilterChanged('order'),
          ),
        ],
      ),
    );
  }
}

/// Lista de historial
class HistoryList extends StatelessWidget {
  final UserRole userRole;

  const HistoryList({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    // TODO: Reemplazar con datos reales del provider
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 15,
      itemBuilder: (context, index) {
        return HistoryCard(index: index, userRole: userRole);
      },
    );
  }
}

/// Tarjeta de item de historial
class HistoryCard extends StatelessWidget {
  final int index;
  final UserRole userRole;

  const HistoryCard({super.key, required this.index, required this.userRole});

  Color _getTypeColor(int type) {
    switch (type) {
      case 0:
        return const Color(0xFF3498db);
      case 1:
        return const Color(0xFF9b59b6);
      case 2:
        return const Color(0xFFe67e22);
      default:
        return Colors.grey;
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

  String _getDate(int index) {
    final daysAgo = index;
    if (daysAgo == 0) return 'Hoy';
    if (daysAgo == 1) return 'Ayer';
    return 'Hace $daysAgo días';
  }

  String _getHistoryTitle(int index) {
    final titles = [
      'Servicio de Detailing Premium',
      'Compra de Neumáticos Michelin',
      'Pedido de Repuestos',
      'Reserva de Mecánica General',
      'Compra de Aceite Sintético',
    ];
    return titles[index % titles.length];
  }

  String _getClientName(int index) {
    final names = [
      'Juan Pérez',
      'María García',
      'Carlos López',
      'Ana Martínez',
      'Pedro Rodríguez',
    ];
    return names[index % names.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(
                  label: _getTypeLabel(index % 3),
                  color: _getTypeColor(index % 3),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: _getStatusLabel(index % 4),
                  color: _getStatusColor(index % 4),
                ),
                const Spacer(),
                Text(
                  _getDate(index),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getHistoryTitle(index),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (userRole == UserRole.admin ||
                userRole == UserRole.operator) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Cliente: ${_getClientName(index)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Total: \$${(50000 + index * 5000).toString()}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                if (index % 4 == 3 && userRole == UserRole.user)
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Repetir pedido
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Repetir'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
