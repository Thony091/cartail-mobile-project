import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/auth/auth.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_floating_action_button.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../providers/categories_provider.dart';
import '../../domain/entities/category.dart';

class ModernConfigCategoriesPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigCategoriesPage';

  const ModernConfigCategoriesPage({super.key});

  @override
  ModernConfigCategoriesPageState createState() =>
      ModernConfigCategoriesPageState();
}

class ModernConfigCategoriesPageState
    extends ConsumerState<ModernConfigCategoriesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(betterAuthProvider);
    final isAdmin = authState.session!.user.isAdmin;

    if (!isAdmin) {
      return const ModernScaffoldWithDrawer(
        title: 'Categorías',
        body: Center(
          child: Text('Acceso exclusivo para administradores'),
        ),
      );
    }

    final categoriesState = ref.watch(categoriesProvider);
    final categories = _filterCategories(categoriesState.categories);

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Categorías',
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
          onRefresh: _refreshCategories,
          child: categoriesState.loading
              ? const Center(child: CircularProgressIndicator())
              : categories.isEmpty
                  ? _EmptyCategoriesView(
                      onCreate: () => context.push('/category-edit/new'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _CategoryCard(
                          category: category,
                          onEdit: () => context.push(
                            '/category-edit/${category.id}',
                          ),
                          onDelete: () => _showDeleteConfirmation(category),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: ModernFloatingActionButton(
        tooltip: 'Crear Categoría',
        icon: Icons.add,
        onPressed: () => context.push('/category-edit/new'),
      ),
    );
  }

  List<Category> _filterCategories(List<Category> categories) {
    if (_searchQuery.trim().isEmpty) return categories;
    final query = _searchQuery.toLowerCase();
    return categories
        .where((category) =>
            category.name.toLowerCase().contains(query) ||
            category.description.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _refreshCategories() async {
    await ref.read(categoriesProvider.notifier).getCategories();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Categoría'),
        content: ModernInputField(
          label: 'Buscar',
          hint: 'Nombre o descripción...',
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

  Future<void> _showDeleteConfirmation(Category category) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Categoría'),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${category.name}"?',
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

    await ref.read(categoriesProvider.notifier).deleteCategory(
          category.id.toString(),
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Categoría eliminada'),
        backgroundColor: Color(0xFFe74c3c),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
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
              Icons.category_outlined,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: category.isActive
                            ? const Color(0xFF27ae60).withOpacity(0.1)
                            : const Color(0xFFe74c3c).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        category.isActive ? 'Activa' : 'Inactiva',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: category.isActive
                              ? const Color(0xFF27ae60)
                              : const Color(0xFFe74c3c),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Orden ${category.order}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
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

class _EmptyCategoriesView extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyCategoriesView({required this.onCreate});

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
              Icons.category_outlined,
              size: 48,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay categorías registradas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea la primera categoría para comenzar',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ModernButton(
            text: 'Crear categoría',
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}
