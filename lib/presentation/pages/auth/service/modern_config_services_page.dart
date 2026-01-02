import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_floating_action_button.dart';

import 'package:portafolio_project/presentation/pages/auth/service/modern_config_services_widgets.dart';

import '../../../shared/widgets/modern_button.dart';

import '../../../shared/widgets/modern_input_field.dart';
import '../modern_scaffold_with_drawer.dart';

class ModernConfigServicesPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigServicesPage';

  const ModernConfigServicesPage({super.key});

  @override
  ModernConfigServicesPageState createState() =>
      ModernConfigServicesPageState();
}

class ModernConfigServicesPageState
    extends ConsumerState<ModernConfigServicesPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    'Detailing',
    'Mecánica',
    'Pintura',
    'Neumáticos',
  ];

  @override
  void initState() {
    super.initState();
    // Cargar servicios al iniciar
    // ref.read(servicesProvider.notifier).getServices();
  }

  @override
  Widget build(BuildContext context) {
    // final servicesState = ref.watch(servicesProvider);

    // Datos simulados para el ejemplo - reemplazar con servicesState.services
    final List<ServiceData> services = _getSimulatedServices();

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Servicios',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterDialog,
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
          onRefresh: _refreshServices,
          child: CustomScrollView(
            slivers: [
              // Header con estadísticas
              SliverToBoxAdapter(
                child: ServicesHeader(totalServices: services.length),
              ),

              // Lista de servicios
              if (services.isEmpty)
                SliverFillRemaining(
                  child: EmptyServicesView(
                    onCreate: () => context.push('/service-edit/new'),
                  ),
                )
              else
                AdminServicesList(
                  services: _filterServices(services),
                  onEdit: (service) =>
                      context.push('/service-edit/${service.id}'),
                  onDelete: (service) async =>
                      await _showDeleteConfirmation(service),
                  onTap: (service) => context.push('/service/${service.id}'),
                  onShowOptions: (service) => _showServiceOptions(service),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: ModernFloatingActionButton(
        tooltip: 'Crear Servicio',
        icon: Icons.add,
        onPressed: () => context.push('/service/new'),
      ),
    );
  }

  void _showServiceOptions(ServiceData service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.visibility, color: Color(0xFF3498db)),
              title: const Text('Ver detalles'),
              onTap: () {
                Navigator.pop(context);
                context.push('/service/${service.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF3498db)),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                context.push('/service-edit/${service.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
              title: const Text('Eliminar'),
              onTap: () async {
                Navigator.pop(context);
                await _showDeleteConfirmation(service);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Servicio'),
        content: ModernInputField(
          label: 'Buscar',
          hint: 'Nombre del servicio...',
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _categories.map((category) {
            return RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(ServiceData service) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Servicio'),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${service.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ModernButton(
                text: 'Eliminar',
                style: ModernButtonStyle.danger,
                onPressed: () {
                  Navigator.of(context).pop(true);
                  // Aquí eliminar el servicio
                  // ref.read(servicesProvider.notifier).deleteService(service.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Servicio eliminado'),
                      backgroundColor: Color(0xFFe74c3c),
                    ),
                  );
                },
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _refreshServices() async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
    // ref.read(servicesProvider.notifier).getServices();
  }

  List<ServiceData> _filterServices(List<ServiceData> services) {
    return services.where((service) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          service.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Todos' || service.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<ServiceData> _getSimulatedServices() {
    return [
      ServiceData(
        id: '1',
        name: 'Detailing Premium',
        category: 'Detailing',
        price: 120000,
        description: 'Servicio completo de detailing',
      ),
      ServiceData(
        id: '2',
        name: 'Cambio de Aceite',
        category: 'Mecánica',
        price: 35000,
        description: 'Cambio de aceite y filtro',
      ),
      ServiceData(
        id: '3',
        name: 'Pintura Completa',
        category: 'Pintura',
        price: 450000,
        description: 'Pintura completa del vehículo',
      ),
    ];
  }
}
