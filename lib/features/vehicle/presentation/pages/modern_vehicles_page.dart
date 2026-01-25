import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_floating_action_button.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../providers/vehicles_provider.dart';
import '../../domain/entities/vehicle.dart';

class ModernVehiclesPage extends ConsumerStatefulWidget {
  static const name = 'ModernVehiclesPage';

  const ModernVehiclesPage({super.key});

  @override
  ModernVehiclesPageState createState() => ModernVehiclesPageState();
}

class ModernVehiclesPageState extends ConsumerState<ModernVehiclesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(betterAuthProvider);
    final isAdmin = authState.session!.user.isAdmin;

    if (!isAdmin) {
      return const ModernScaffoldWithDrawer(
        title: 'Modelos de Vehículo',
        body: Center(
          child: Text('Acceso exclusivo para administradores'),
        ),
      );
    }

    final vehiclesState = ref.watch(vehiclesProvider);
    final vehicles = _filterVehicles(vehiclesState.vehicles);

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Modelos de Vehículo',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshVehicles,
          child: vehiclesState.loading
              ? const Center(child: CircularProgressIndicator())
              : vehicles.isEmpty
                  ? _EmptyVehiclesView(
                      onCreate: () => context.push('/vehicle-edit/new'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: vehicles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return _VehicleCard(
                          vehicle: vehicle,
                          onEdit: () => context.push(
                            '/vehicle-edit/${vehicle.id}',
                          ),
                          onDelete: () => _showDeleteConfirmation(vehicle),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: ModernFloatingActionButton(
        tooltip: 'Crear modelo',
        icon: Icons.add,
        onPressed: () => context.push('/vehicle-edit/new'),
      ),
    );
  }

  List<Vehicle> _filterVehicles(List<Vehicle> vehicles) {
    if (_searchQuery.trim().isEmpty) return vehicles;
    final query = _searchQuery.toLowerCase();
    return vehicles
        .where((vehicle) =>
            vehicle.brand.toLowerCase().contains(query) ||
            vehicle.model.toLowerCase().contains(query) ||
            vehicle.year.toLowerCase().contains(query) ||
            vehicle.trim.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _refreshVehicles() async {
    await ref.read(vehiclesProvider.notifier).getVehicles();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Modelo'),
        content: ModernInputField(
          label: 'Buscar',
          hint: 'Marca, modelo, año o trim...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Modelo'),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${vehicle.brand} ${vehicle.model}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ModernButton(
                text: 'Eliminar',
                style: ModernButtonStyle.danger,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    await ref.read(vehiclesProvider.notifier).deleteVehicle(
          vehicle.id.toString(),
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Modelo eliminado'),
        backgroundColor: Color(0xFFe74c3c),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Año ${vehicle.year} · ${vehicle.trim}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID ${vehicle.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF3498db)),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyVehiclesView extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyVehiclesView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              size: 48,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay modelos registrados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea el primer modelo para comenzar',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ModernButton(
            text: 'Crear modelo',
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}
