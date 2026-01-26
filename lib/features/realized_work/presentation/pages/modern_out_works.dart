import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../../shared/presentation/shared/widgets/widgets.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'modern_out_works_widgets.dart';
import '../providers/works_provider.dart';
import '../../domain/entities/works.dart';

class ModernOurWorksPage extends ConsumerStatefulWidget {
  static const name = 'ModernOurWorksPage';

  const ModernOurWorksPage({super.key});

  @override
  ModernOurWorksPageState createState() => ModernOurWorksPageState();
}

class ModernOurWorksPageState extends ConsumerState<ModernOurWorksPage> {
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
    final worksState = ref.watch(worksProvider);
    final filtersState = ref.watch(worksFiltersProvider);
    final filtersNotifier = ref.read(worksFiltersProvider.notifier);
    final authState = ref.watch(betterAuthProvider);
    final isAdmin = authState.session?.user.isAdmin;
    final List<Works> works = worksState.works;
    final filteredWorks = _filterWorks(works);
    final categories = _buildCategories(works);

    if (filtersState.isSearching && !_searchFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }

    return ModernScaffoldWithDrawer(
      title: (isAdmin != null && isAdmin) ? 'Gestión de Trabajos' : 'Nuestros Trabajos',
      titleWidget: (isAdmin == null || !isAdmin) && filtersState.isSearching
          ? Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 36,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Buscar trabajo...',
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
      appBarActions: (isAdmin == null || !isAdmin)
          ? [
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
            ]
          : [],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(.1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: Column(
          children: [
            // Filtros de categorías
            WorkCategoryTabs(
              categories: categories,
              selectedCategory: filtersState.selectedCategory,
              onCategorySelected: filtersNotifier.setCategory,
            ),

            // Contenido filtrado
            Expanded(
              child: WorksGrid(
                works: filteredWorks,
                isAdmin: isAdmin != null && isAdmin,
                onWorkTap: _showWorkDetail,
                onRefresh: _refreshWorks,
                onDeleteConfirmation: _showDeleteWorkConfirmation,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin != null && isAdmin
          ? ModernFloatingActionButton(
              icon: Icons.add_a_photo,
              tooltip: 'Agregar Trabajo',
              onPressed: () {
                // Navegar a crear trabajo
              },
            )
          : null,
    );
  }

  List<Works> _filterWorks(List<Works> works) {
    final filtersState = ref.read(worksFiltersProvider);
    final query = filtersState.searchQuery.trim().toLowerCase();
    return works.where((work) {
      final matchesSearch =
          query.isEmpty ||
          work.name.toLowerCase().contains(query) ||
          work.description.toLowerCase().contains(query);
      final matchesCategory =
          filtersState.selectedCategory == 'Todos' ||
          getWorkCategory(work) == filtersState.selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> _buildCategories(List<Works> works) {
    final categories = <String>{'Todos'};
    for (final work in works) {
      categories.add(getWorkCategory(work));
    }
    return categories.toList();
  }

  Future<void> _refreshWorks() async {
    await ref.read(worksProvider.notifier).getWorks();
  }

  void _showWorkDetail(Works work) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkDetailSheet(work: work),
    );
  }

  Future<bool> _showDeleteWorkConfirmation(Works work) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Trabajo'),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${work.name}"?',
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

    await ref.read(worksProvider.notifier).deleteWork(work.id);
    return true;
  }
}
