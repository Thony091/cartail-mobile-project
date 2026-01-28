import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:portafolio_project/features/realized_work/presentation/pages/modern_config_works_widgets.dart';
import '../providers/works_provider.dart';
import '../../domain/entities/works.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_floating_action_button.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';

class ModernConfigWorksPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigWorksPage';

  const ModernConfigWorksPage({super.key});

  @override
  ModernConfigWorksPageState createState() => ModernConfigWorksPageState();
}

class ModernConfigWorksPageState extends ConsumerState<ModernConfigWorksPage> {
  String _searchQuery = '';
  String _sortBy = 'Recientes';

  final List<String> _sortOptions = ['Recientes', 'Antiguos', 'A-Z', 'Z-A'];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final worksState = ref.watch(worksProvider);
    final List<Works> works = _filterAndSortWorks(worksState.works);

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Trabajos',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: const Icon(Icons.sort, color: Colors.white),
          onPressed: _showSortDialog,
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
          onRefresh: _refreshWorks,
          child: CustomScrollView(
            slivers: [
              // Header con estadísticas
              SliverToBoxAdapter(
                child: WorksHeader(totalWorks: worksState.works.length),
              ),

              // Grid de trabajos
              if (worksState.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (works.isEmpty)
                SliverFillRemaining(
                  child: EmptyWorksView(
                    onCreateWork: () => context.push('/work-edit/new'),
                  ),
                )
              else
                WorksGrid(
                  works: works,
                  onWorkTap: _showWorkOptions,
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: ModernFloatingActionButton(
        tooltip: 'Crear Trabajo',
        icon: Icons.add,
        size: 48,
        onPressed: () => context.push('/work-edit/new'),
      ),
    );
  }

  void _showWorkOptions(Works work) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkOptionsSheet(
        work: work,
        onEdit: () {
          Navigator.pop(context);
          context.push('/work-edit/${work.id}');
        },
        onDelete: () async {
          Navigator.pop(context);
          await _showDeleteConfirmation(work);
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => SearchWorksDialog(
        onSearch: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => SortWorksDialog(
        currentSort: _sortBy,
        sortOptions: _sortOptions,
        onSortChanged: (value) {
          setState(() => _sortBy = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(Works work) async {
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trabajo eliminado'),
          backgroundColor: Color(0xFFe74c3c),
        ),
      );
    }

    return true;
  }

  Future<void> _refreshWorks() async {
    await ref.read(worksProvider.notifier).getWorks();
  }

  List<Works> _filterAndSortWorks(List<Works> works) {
    var filtered = works.where((work) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          work.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    // Ordenar según selección
    switch (_sortBy) {
      case 'Recientes':
        break;
      case 'Antiguos':
        filtered = filtered.reversed.toList();
        break;
      case 'A-Z':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Z-A':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    return filtered;
  }
}
