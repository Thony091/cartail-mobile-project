import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:portafolio_project/presentation/pages/auth/realized-works/modern_config_works_widgets.dart';

import '../../../shared/widgets/modern_button.dart';
import '../../../shared/widgets/modern_floating_action_button.dart';
import '../../../shared/widgets/modern_input_field.dart';
import '../modern_scaffold_with_drawer.dart';

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
    // Cargar trabajos al iniciar
    // ref.read(worksProvider.notifier).getWorks();
  }

  @override
  Widget build(BuildContext context) {
    // final worksState = ref.watch(worksProvider);

    // Datos simulados para el ejemplo - reemplazar con worksState.works
    final List<WorkData> works = _getSimulatedWorks();

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
              SliverToBoxAdapter(child: WorksHeader(totalWorks: works.length)),

              // Grid de trabajos
              if (works.isEmpty)
                SliverFillRemaining(
                  child: EmptyWorksView(
                    onCreateWork: () => context.push('/work-edit/new'),
                  ),
                )
              else
                WorksGrid(
                  works: _filterAndSortWorks(works),
                  onWorkTap: _showWorkOptions,
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: ModernFloatingActionButton(
        tooltip: 'Crear Trabajo',
        icon: Icons.add,
        onPressed: () => context.push('/work-edit/new'),
      ),
    );
  }

  void _showWorkOptions(WorkData work) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    work.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(work.date),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF3498db)),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                context.push('/work-edit/${work.id}');
              },
            ),
            ListTile(
              leading: Icon(
                work.isFeatured ? Icons.star : Icons.star_outline,
                color: const Color(0xFFf39c12),
              ),
              title: Text(
                work.isFeatured ? 'Quitar de destacados' : 'Destacar',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleFeatured(work);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
              title: const Text('Eliminar'),
              onTap: () async {
                Navigator.pop(context);
                await _showDeleteConfirmation(work);
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
        title: const Text('Buscar Trabajo'),
        content: ModernInputField(
          label: 'Buscar',
          hint: 'Título del trabajo...',
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

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordenar por'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sortOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _toggleFeatured(WorkData work) {
    // Aquí alternar el estado destacado
    // ref.read(worksProvider.notifier).toggleFeatured(work.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          work.isFeatured ? 'Quitado de destacados' : 'Marcado como destacado',
        ),
        backgroundColor: const Color(0xFFf39c12),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(WorkData work) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Trabajo'),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${work.title}"?',
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
                  // Aquí eliminar el trabajo
                  // ref.read(worksProvider.notifier).deleteWork(work.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trabajo eliminado'),
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

  Future<void> _refreshWorks() async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
    // ref.read(worksProvider.notifier).getWorks();
  }

  List<WorkData> _filterAndSortWorks(List<WorkData> works) {
    var filtered = works.where((work) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          work.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    // Ordenar según selección
    switch (_sortBy) {
      case 'Recientes':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Antiguos':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'A-Z':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Z-A':
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

    return filtered;
  }

  List<WorkData> _getSimulatedWorks() {
    return [
      WorkData(
        id: '1',
        title: 'Renault Duster Detailing Premium',
        description: 'Lavado profundo, pulido y encerado...',
        vehicle: 'Renault Duster 2019',
        date: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: 'https://placeholder.com/car1.jpg',
        isFeatured: true,
      ),
      WorkData(
        id: '2',
        title: 'Chevrolet Onix Limpieza Interior',
        description: 'Limpieza de tapicería y desinfección...',
        vehicle: 'Chevrolet Onix 2021',
        date: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl: 'https://placeholder.com/car2.jpg',
        isFeatured: false,
      ),
      WorkData(
        id: '3',
        title: 'Toyota Hilux Restauración de Faros',
        description: 'Pulido y laqueado de ópticas delanteras...',
        vehicle: 'Toyota Hilux 2018',
        date: DateTime.now().subtract(const Duration(days: 8)),
        imageUrl: 'https://placeholder.com/car3.jpg',
        isFeatured: false,
      ),
    ];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
