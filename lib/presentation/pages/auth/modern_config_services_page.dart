
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_floating_action_button.dart';

import '../../shared/widgets/modern_button.dart';
import '../../shared/widgets/modern_card.dart';
import '../../shared/widgets/modern_input_field.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernConfigServicesPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigServicesPage';
  
  const ModernConfigServicesPage({super.key});

  @override
  ModernConfigServicesPageState createState() => ModernConfigServicesPageState();
}

class ModernConfigServicesPageState extends ConsumerState<ModernConfigServicesPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  
  final List<String> _categories = [
    'Todos', 'Detailing', 'Mecánica', 'Pintura', 'Neumáticos'
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
                child: _buildHeaderSection(services.length),
              ),
              
              // Lista de servicios
              if (services.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                _buildAdminServicesList(services),
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

  Widget _buildHeaderSection(int totalServices) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panel de Administración',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona tus servicios desde aquí',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          
          // Estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Servicios',
                  totalServices.toString(),
                  Icons.build_circle,
                  const Color(0xFF3498db),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Activos',
                  totalServices.toString(),
                  Icons.check_circle,
                  const Color(0xFF27ae60),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminServicesList(List<ServiceData> services) {
    final filteredServices = _filterServices(services);
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final service = filteredServices[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 50),
              child: _buildServiceAdminCard(service),
            );
          },
          childCount: filteredServices.length,
        ),
      ),
    );
  }

  Widget _buildServiceAdminCard(ServiceData service) {
    return Dismissible(
      key: Key(service.id),
      background: _buildDismissBackground(
        color: const Color(0xFF3498db),
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildDismissBackground(
        color: const Color(0xFFe74c3c),
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Editar
          context.push('/service-edit/${service.id}');
          return false;
        } else {
          // Eliminar
          return await _showDeleteConfirmation(service);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ModernCard(
          child: InkWell(
            onTap: () => context.push('/service/${service.id}'),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  // Imagen del servicio
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF3498db).withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.car_repair,
                      color: Color(0xFF3498db),
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Información del servicio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2c3e50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF27ae60).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: Color(0xFF27ae60),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Activo',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF27ae60),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$${service.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3498db),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Botón de más opciones
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showServiceOptions(service),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.build_outlined,
              size: 60,
              color: Color(0xFF3498db),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'No hay servicios registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Comienza creando tu primer servicio',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7f8c8d),
            ),
          ),
          
          const SizedBox(height: 32),
          
          ModernButton(
            text: 'Crear Servicio',
            icon: Icons.add,
            onPressed: () => context.push('/service-edit/new'),
          ),
        ],
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
        content: Text('¿Estás seguro de que deseas eliminar "${service.name}"?'),
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
    ) ?? false;
  }

  Future<void> _refreshServices() async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
    // ref.read(servicesProvider.notifier).getServices();
  }

  List<ServiceData> _filterServices(List<ServiceData> services) {
    return services.where((service) {
      final matchesSearch = _searchQuery.isEmpty ||
          service.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Todos' ||
          service.category == _selectedCategory;
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

class ServiceData {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;

  ServiceData({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
  });
}