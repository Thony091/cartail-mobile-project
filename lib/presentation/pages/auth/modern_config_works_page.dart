import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/modern_button.dart';
import '../../shared/widgets/modern_card.dart';
import '../../shared/widgets/modern_floating_action_button.dart';
import '../../shared/widgets/modern_input_field.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernConfigWorksPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigWorksPage';
  
  const ModernConfigWorksPage({super.key});

  @override
  ModernConfigWorksPageState createState() => ModernConfigWorksPageState();
}

class ModernConfigWorksPageState extends ConsumerState<ModernConfigWorksPage> {
  String _searchQuery = '';
  String _sortBy = 'Recientes';
  
  final List<String> _sortOptions = [
    'Recientes', 'Antiguos', 'A-Z', 'Z-A'
  ];

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
              SliverToBoxAdapter(
                child: _buildHeaderSection(works.length),
              ),
              
              // Grid de trabajos
              if (works.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                _buildWorksGrid(works),
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

  Widget _buildHeaderSection(int totalWorks) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nuestros Trabajos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona el portafolio de trabajos realizados',
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
                  'Total',
                  totalWorks.toString(),
                  Icons.photo_library,
                  const Color(0xFF9b59b6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Este Mes',
                  '5',
                  Icons.add_photo_alternate,
                  const Color(0xFF3498db),
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

  Widget _buildWorksGrid(List<WorkData> works) {
    final filteredWorks = _filterAndSortWorks(works);
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final work = filteredWorks[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 50),
              child: _buildWorkCard(work),
            );
          },
          childCount: filteredWorks.length,
        ),
      ),
    );
  }

  Widget _buildWorkCard(WorkData work) {
    return ModernCard(
      child: InkWell(
        onTap: () => _showWorkOptions(work),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del trabajo
            Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    color: const Color(0xFF3498db).withOpacity(0.1),
                    image: work.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(work.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: work.imageUrl == null
                      ? const Center(
                          child: Icon(
                            Icons.photo_camera,
                            size: 50,
                            color: Color(0xFF3498db),
                          ),
                        )
                      : null,
                ),
                
                // Badge de destacado
                if (work.isFeatured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf39c12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Destacado',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Información del trabajo
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    work.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(work.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
              color: const Color(0xFF9b59b6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              size: 60,
              color: Color(0xFF9b59b6),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'No hay trabajos registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Comienza agregando trabajos al portafolio',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7f8c8d),
            ),
          ),
          
          const SizedBox(height: 32),
          
          ModernButton(
            text: 'Crear Trabajo',
            icon: Icons.add,
            onPressed: () => context.push('/work-edit/new'),
          ),
        ],
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
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
              title: Text(work.isFeatured ? 'Quitar de destacados' : 'Destacar'),
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
        content: Text('¿Estás seguro de que deseas eliminar "${work.title}"?'),
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
    ) ?? false;
  }

  Future<void> _refreshWorks() async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
    // ref.read(worksProvider.notifier).getWorks();
  }

  List<WorkData> _filterAndSortWorks(List<WorkData> works) {
    var filtered = works.where((work) {
      final matchesSearch = _searchQuery.isEmpty ||
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

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  List<WorkData> _getSimulatedWorks() {
    return [
      WorkData(
        id: '1',
        title: 'Renault Duster Detailing Premium',
        imageUrl: null,
        date: DateTime.now().subtract(const Duration(days: 5)),
        isFeatured: true,
      ),
      WorkData(
        id: '2',
        title: 'Mini Cooper Works Transformación',
        imageUrl: null,
        date: DateTime.now().subtract(const Duration(days: 10)),
        isFeatured: true,
      ),
      WorkData(
        id: '3',
        title: 'Pintura Completa Camioneta',
        imageUrl: null,
        date: DateTime.now().subtract(const Duration(days: 15)),
        isFeatured: false,
      ),
      WorkData(
        id: '4',
        title: 'Restauración Interior',
        imageUrl: null,
        date: DateTime.now().subtract(const Duration(days: 20)),
        isFeatured: false,
      ),
    ];
  }
}

class WorkData {
  final String id;
  final String title;
  final String? imageUrl;
  final DateTime date;
  final bool isFeatured;

  WorkData({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.date,
    this.isFeatured = false,
  });
}