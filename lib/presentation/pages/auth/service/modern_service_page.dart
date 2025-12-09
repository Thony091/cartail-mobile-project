import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:portafolio_project/presentation/pages/auth/home/views/components/stat_card_widget.dart';
import 'package:portafolio_project/presentation/pages/auth/service/views/admin_services_list_widget.dart';
import 'package:portafolio_project/presentation/pages/auth/service/views/components/empty_state_widget.dart';
import 'package:portafolio_project/presentation/pages/auth/service/views/user_service_list_widget.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/services_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../modern_scaffold_with_drawer.dart';

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
              const Color(0xFF667eea).withValues(alpha: .1),
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
                const SliverFillRemaining(
                  child: EmptyStateWidget(),
                )
              else if (isAdmin)
                AdminServiceListWidget(services: services)
              else
                UserServiceListWidget(services: services),
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
    return _HeaderSection(
      categories: _categories,
      selectedCategory: _selectedCategory,
      onSearchChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      onCategorySelected: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
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
      ServiceData(
        id: '4',
        name: 'Pintura Completa',
        description: 'Pintura completa del vehículo con garantía',
        category: 'Pintura',
        minPrice: 350000,
        maxPrice: 550000,
        images: [],
      ),
      ServiceData(
        id: '5',
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

// Helper function para obtener íconos de servicio
IconData getServiceIcon(String category) {
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

// Widget: Header Section
class _HeaderSection extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;

  const _HeaderSection({
    required this.categories,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estadísticas rápidas
          FadeInDown(
            child: const Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    value: '24',
                    label: 'Servicios',
                    icon: Icons.build,
                    color: Color(0xFF3498db),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StatCardWidget(
                    value: '156',
                    label: 'Completados',
                    icon: Icons.check_circle,
                    color: Color(0xFF27ae60),
                  ),
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
              onChanged: onSearchChanged,
            ),
          ),

          const SizedBox(height: 16),

          // Filtros de categoría
          FadeInRight(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) => onCategorySelected(category),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF3498db).withValues(alpha: .2),
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