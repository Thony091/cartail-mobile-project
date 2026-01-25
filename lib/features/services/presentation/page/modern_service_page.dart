import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
// import 'package:animate_do/animate_do.dart'; removed unused
// import 'package:portafolio_project/presentation/pages/auth/home/views/components/stat_card_widget.dart'; removed unused
import 'package:portafolio_project/features/services/presentation/page/views/admin_services_list_widget.dart';
import 'package:portafolio_project/features/services/presentation/page/views/components/empty_state_widget.dart';
import 'package:portafolio_project/features/services/presentation/page/views/user_service_list_widget.dart';
import 'modern_service_widgets.dart'; // Add this import

import '../providers/services_provider.dart';
import '../../../shared/presentation/shared/widgets/widgets.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../domain/entities/services.dart';

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
    'Todos',
    'Detailing',
    'Mecánica',
    'Pintura',
    'Neumáticos',
  ];

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesProvider);
    final authState = ref.watch(betterAuthProvider);
    final isAdmin = authState.session?.user.isAdmin;
    final totalServices = servicesState.services.length;
    final activeServices = servicesState.services
        .where((service) => service.isActive)
        .length;

    final List<Services> services = _filterServices(servicesState.services);
    // final bool isAdmin = false; // authState.userData?.isAdmin ?? false

    return ModernScaffoldWithDrawer(
      title: (isAdmin != null && isAdmin) 
        ? 'Gestión de Servicios' 
        : 'Nuestros Servicios',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
        if (isAdmin != null && isAdmin)
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
                child: ServiceHeaderSection(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  totalServices: totalServices,
                  activeServices: activeServices,
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
                ),
              ),

              // Lista de servicios
              if (servicesState.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (services.isEmpty)
                const SliverFillRemaining(child: EmptyStateWidget())
              else if (isAdmin != null && isAdmin)
                AdminServiceListWidget(services: services)
              else
                UserServiceListWidget(services: services),
            ],
          ),
        ),
      ),
      floatingActionButton: isAdmin != null && isAdmin
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

  Future<void> _refreshServices() async {
    await ref.read(servicesProvider.notifier).getServices();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => SearchServicesDialog(
        onSearch: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterServicesDialog(
        onApply: () {
          // Logic to apply filters if needed
          // For now just closing as per original logic which didn't do much
        },
      ),
    );
  }

  List<Services> _filterServices(List<Services> services) {
    return services.where((service) {
      final category = getServiceCategory(service);
      final matchesSearch =
          _searchQuery.isEmpty ||
          service.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Todos' || category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }
}
