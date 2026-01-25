import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_floating_action_button.dart';

import 'package:portafolio_project/features/services/presentation/page/modern_config_services_widgets.dart';
import 'package:portafolio_project/features/category/presentation/providers/categories_provider.dart';
import 'package:portafolio_project/features/category/domain/entities/category.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../providers/services_provider.dart';
import '../../domain/entities/services.dart';

class ModernConfigServicesPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigServicesPage';

  const ModernConfigServicesPage({super.key});

  @override
  ModernConfigServicesPageState createState() =>
      ModernConfigServicesPageState();
}

class ModernConfigServicesPageState
    extends ConsumerState<ModernConfigServicesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

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
    final List<Services> services = _filterServices(servicesState.services);
    final categoriesState = ref.watch(categoriesProvider);
    final categories = categoriesState.categories
        .where((category) => category.isActive)
        .toList();

    if (filtersState.isSearching && !_searchFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Servicios',
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
        else ...[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              filtersNotifier.startSearch();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchFocusNode.requestFocus();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: categoriesState.loading
                ? null
                : () => _showFilterDialog(categories),
          ),
        ],
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
                child: ServicesHeader(
                  totalServices: servicesState.services.length,
                ),
              ),

              // Lista de servicios
              if (servicesState.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (services.isEmpty)
                SliverFillRemaining(
                  child: EmptyServicesView(
                    onCreate: () => context.push('/service/new'),
                  ),
                )
              else
                AdminServicesList(
                  services: services,
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

  void _showServiceOptions(Services service) {
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

  void _showFilterDialog(List<Category> categories) {
    final filtersNotifier = ref.read(servicesFiltersProvider.notifier);
    final filtersState = ref.read(servicesFiltersProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Categoría'),
        content: categories.isEmpty
            ? const Text('No hay categorías disponibles')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<int>(
                    title: const Text('Todos'),
                    value: 0,
                    groupValue: filtersState.selectedCategoryId,
                    onChanged: (value) {
                      filtersNotifier.setCategoryId(value ?? 0);
                      Navigator.pop(context);
                    },
                  ),
                  ...categories.map((category) {
                    return RadioListTile<int>(
                      title: Text(category.name),
                      value: category.id,
                      groupValue: filtersState.selectedCategoryId,
                      onChanged: (value) {
                        filtersNotifier.setCategoryId(value ?? 0);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(Services service) async {
    final confirmed = await showDialog<bool>(
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
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) {
      return false;
    }

    final deleted =
        await ref.read(servicesProvider.notifier).deleteService(service.id);

    if (!mounted) {
      return deleted;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Servicio eliminado' : 'No se pudo eliminar el servicio',
        ),
        backgroundColor:
            deleted ? const Color(0xFFe74c3c) : const Color(0xFFf39c12),
      ),
    );

    return deleted;
  }

  Future<void> _refreshServices() async {
    await ref.read(servicesProvider.notifier).getServices();
  }

  List<Services> _filterServices(List<Services> services) {
    final filtersState = ref.read(servicesFiltersProvider);
    return services.where((service) {
      final matchesSearch =
          filtersState.searchQuery.isEmpty ||
          service.name
              .toLowerCase()
              .contains(filtersState.searchQuery.toLowerCase());
      final matchesCategory =
          filtersState.selectedCategoryId == 0 ||
          service.categoryId == filtersState.selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList();
  }
}
