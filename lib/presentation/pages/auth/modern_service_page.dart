import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/auth_provider.dart';
import '../../providers/services_provider.dart';
import '../../shared/widgets/widgets.dart';
import 'modern_scaffold_with_drawer.dart';
import 'modern_service_card.dart';

class ModernServicesPage extends ConsumerStatefulWidget {
  static const name = 'ModernServicesPage';
  
  const ModernServicesPage({super.key});

  @override
  ModernServicesPageState createState() => ModernServicesPageState();
}

class ModernServicesPageState extends ConsumerState<ModernServicesPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  
  final List<String> _categories = [
    'Todos', 'Detailing', 'Mecánica', 'Pintura', 'Neumáticos'
  ];

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesProvider);
    final authState = ref.watch(authProvider);
    final isAdmin = authState.userData?.isAdmin ?? false;
    
    // Datos simulados para el ejemplo
    final List<ServiceData> services = _getSimulatedServices();
    // final bool isAdmin = false; // authState.userData?.isAdmin ?? false

    return ModernScaffoldWithDrawer(
      title: isAdmin ? 'Gestión de Servicios' : 'Nuestros Servicios',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
        if (isAdmin)
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
              // Header con filtros
              SliverToBoxAdapter(
                child: _buildHeaderSection(),
              ),
              
              // Lista de servicios
              if (services.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else if (isAdmin)
                _buildAdminServicesList(services)
              else
                _buildUserServicesList(services),
            ],
          ),
        ),
      ),
      floatingActionButton: isAdmin
          ? ModernFloatingActionButton(
              icon: Icons.add,
              tooltip: 'Agregar Servicio',
              onPressed: () {
                // Navegar a crear servicio
              },
            )
          : null,
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estadísticas rápidas
          FadeInDown(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('24', 'Servicios', Icons.build, const Color(0xFF3498db)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('156', 'Completados', Icons.check_circle, const Color(0xFF27ae60)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Barra de búsqueda
          FadeInLeft(
            child: ModernInputField(
              hint: 'Buscar servicios...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filtros de categoría
          FadeInRight(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF3498db).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF3498db),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF3498db) : const Color(0xFF7f8c8d),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7f8c8d),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminServicesList(List<ServiceData> services) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final service = services[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 100),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildAdminServiceCard(service),
            ),
          );
        },
        childCount: services.length,
      ),
    );
  }

  Widget _buildUserServicesList(List<ServiceData> services) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 100),
            child: ModernServiceCard(
              icon: _getServiceIcon(service.category),
              title: service.name,
              subtitle: service.description,
              price: '\$${service.minPrice} - \$${service.maxPrice}',
              images: service.images,
              onTap: () {
                // Navegar a detalles del servicio
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminServiceCard(ServiceData service) {
    return Dismissible(
      key: Key(service.id),
      direction: DismissDirection.horizontal,
      background: _buildDismissBackground(Colors.blue, Icons.edit, Alignment.centerLeft),
      secondaryBackground: _buildDismissBackground(Colors.red, Icons.delete, Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Editar servicio
          return false;
        } else {
          // Eliminar servicio
          return await _showDeleteConfirmation(service);
        }
      },
      child: ModernCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagen del servicio
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: const Color(0xFF3498db).withOpacity(0.1),
                child: service.images.isNotEmpty
                    ? Image.network(
                        service.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _getServiceIcon(service.category),
                            color: const Color(0xFF3498db),
                            size: 32,
                          );
                        },
                      )
                    : Icon(
                        _getServiceIcon(service.category),
                        color: const Color(0xFF3498db),
                        size: 32,
                      ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7f8c8d),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27ae60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${service.minPrice} - \$${service.maxPrice}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF27ae60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Acciones
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3498db)),
                  onPressed: () {
                    // Editar servicio
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                  onPressed: () async {
                    if (await _showDeleteConfirmation(service)) {
                      // Eliminar servicio
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissBackground(Color color, IconData icon, Alignment alignment) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(icon, color: Colors.white, size: 28),
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
            'No hay servicios disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega algunos servicios para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'detailing':
        return Icons.cleaning_services;
      case 'mecánica':
        return Icons.build;
      case 'pintura':
        return Icons.brush;
      case 'neumáticos':
        return Icons.circle_outlined;
      default:
        return Icons.car_repair;
    }
  }

  Future<void> _refreshServices() async {
    // ref.read(servicesProvider.notifier).getServices();
    await Future.delayed(const Duration(seconds: 1));
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Servicios'),
        content: ModernInputField(
          hint: 'Escribe el nombre del servicio...',
          // autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ModernButton(
            text: 'Buscar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 20),
            // Aquí irían los filtros adicionales
            ModernButton(
              text: 'Aplicar Filtros',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
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
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;
  }

  List<ServiceData> _getSimulatedServices() {
    return [
      ServiceData(
        id: '1',
        name: 'Detailing Premium',
        description: 'Limpieza profunda interior y exterior con protección cerám',
        category: 'Detailing',
        minPrice: 80000,
        maxPrice: 120000,
        images: [],
      ),
      ServiceData(
        id: '2',
        name: 'Cambio de Aceite',
        description: 'Cambio de aceite y filtros con revisión general',
        category: 'Mecánica',
        minPrice: 25000,
        maxPrice: 45000,
        images: [],
      ),
      ServiceData(
        id: '3',
        name: 'Pintura Completa',
        description: 'Pintura completa del vehículo con garantía',
        category: 'Pintura',
        minPrice: 350000,
        maxPrice: 550000,
        images: [],
      ),
    ];
  }
}

class ServiceData {
  final String id;
  final String name;
  final String description;
  final String category;
  final int minPrice;
  final int maxPrice;
  final List<String> images;

  ServiceData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.images,
  });
}
