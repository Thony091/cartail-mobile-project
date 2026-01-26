import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/category/presentation/providers/categories_provider.dart';
import 'package:portafolio_project/features/category/domain/entities/category.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesProvider);
    final filtersState = ref.watch(servicesFiltersProvider);
    final filtersNotifier = ref.read(servicesFiltersProvider.notifier);
    final authState = ref.watch(betterAuthProvider);
    final isAdmin = authState.session?.user.isAdmin;
    final categoriesState = ref.watch(categoriesProvider);
    final categories = categoriesState.categories
        .where((category) => category.isActive)
        .toList();
    final totalServices = servicesState.services.length;
    final activeServices = servicesState.services
        .where((service) => service.isActive)
        .length;

    final List<Services> services = _filterServices(servicesState.services);
    // final bool isAdmin = false; // authState.userData?.isAdmin ?? false

    if (filtersState.isSearching && !_searchFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }

    return ModernScaffoldWithDrawer(
      title: (isAdmin != null && isAdmin) 
        ? 'Gestión de Servicios' 
        : 'Nuestros Servicios',
      titleWidget: filtersState.isSearching
          ? Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF3498db).withValues(alpha: 0.6),
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    cursorColor: const Color(0xFF2c3e50),
                    keyboardAppearance: Brightness.light,
                    textInputAction: TextInputAction.search,
                    onChanged: filtersNotifier.setSearchQuery,
                    style: const TextStyle(
                      color: Color(0xFF2c3e50),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Buscar servicio...',
                      hintStyle: TextStyle(color: Color(0xFF7f8c8d)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            )
          : null,
      appBarActions: [
        if (filtersState.isSearching)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              filtersNotifier.stopSearch();
              _searchController.clear();
              _searchFocusNode.unfocus();
            },
          )
        else
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              filtersNotifier.startSearch();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchFocusNode.requestFocus();
              });
            },
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
                  categories: _buildCategoryLabels(categories),
                  selectedCategory: _selectedCategoryLabel(
                    filtersState.selectedCategoryId,
                    categories,
                  ),
                  totalServices: totalServices,
                  activeServices: activeServices,
                  onSearchChanged: filtersNotifier.setSearchQuery,
                  onCategorySelected: (category) {
                    final categoryId = _categoryIdFromLabel(category, categories);
                    filtersNotifier.setCategoryId(categoryId);
                  },
                  showSearchBar: false,
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
    final filtersState = ref.read(servicesFiltersProvider);
    return services.where((service) {
      final category = getServiceCategory(service);
      final matchesSearch =
          filtersState.searchQuery.isEmpty ||
          service.name
              .toLowerCase()
              .contains(filtersState.searchQuery.toLowerCase());
      final matchesCategory =
          filtersState.selectedCategoryId == 0 ||
          service.categoryId == filtersState.selectedCategoryId ||
          category == _selectedCategoryLabel(
            filtersState.selectedCategoryId,
            ref.read(categoriesProvider).categories,
          );
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> _buildCategoryLabels(List<Category> categories) {
    return ['Todos', ...categories.map((category) => category.name)];
  }

  String _selectedCategoryLabel(int selectedId, List<Category> categories) {
    if (selectedId == 0) return 'Todos';
    final match = categories.where((category) => category.id == selectedId);
    return match.isNotEmpty ? match.first.name : 'Todos';
  }

  int _categoryIdFromLabel(String label, List<Category> categories) {
    if (label == 'Todos') return 0;
    final match = categories.where((category) => category.name == label);
    return match.isNotEmpty ? match.first.id : 0;
  }
}
