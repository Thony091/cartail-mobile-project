import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../shared/widgets/widgets.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernOurWorksPage extends ConsumerStatefulWidget {
  static const name = 'ModernOurWorksPage';
  
  const ModernOurWorksPage({super.key});

  @override
  ModernOurWorksPageState createState() => ModernOurWorksPageState();
}

class ModernOurWorksPageState extends ConsumerState<ModernOurWorksPage> 
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final worksState = ref.watch(worksProvider);
    // final authState = ref.watch(authProvider);
    
    final bool isAdmin = false; // authState.userData?.isAdmin ?? false
    final List<WorkData> works = _getSimulatedWorks();

    return ModernScaffoldWithDrawer(
      title: isAdmin ? 'Gestión de Trabajos' : 'Nuestros Trabajos',
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.05),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: Column(
          children: [
            // Tabs de categorías
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF3498db), const Color(0xFF2980b9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF7f8c8d),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Todos'),
                  Tab(text: 'Detailing'),
                  Tab(text: 'Restauración'),
                ],
              ),
            ),
            
            // Contenido de las tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWorksGrid(works, isAdmin),
                  _buildWorksGrid(works.where((w) => w.category == 'Detailing').toList(), isAdmin),
                  _buildWorksGrid(works.where((w) => w.category == 'Restauración').toList(), isAdmin),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
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

  Widget _buildWorksGrid(List<WorkData> works, bool isAdmin) {
    if (works.isEmpty) {
      return _buildEmptyWorksState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh works
        await Future.delayed(const Duration(seconds: 1));
      },
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: isAdmin ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        itemCount: works.length,
        itemBuilder: (context, index) {
          final work = works[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 100),
            child: isAdmin
                ? _buildAdminWorkCard(work)
                : _buildUserWorkCard(work),
          );
        },
      ),
    );
  }

  Widget _buildUserWorkCard(WorkData work) {
    return GestureDetector(
      onTap: () {
        _showWorkDetail(work);
      },
      child: ModernCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: work.image.isNotEmpty
                    ? Image.network(
                        work.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF3498db).withOpacity(0.1),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Color(0xFF3498db),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFF3498db).withOpacity(0.1),
                        child: const Icon(
                          Icons.car_repair,
                          size: 48,
                          color: Color(0xFF3498db),
                        ),
                      ),
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    work.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    work.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7f8c8d),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(work.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      work.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(work.category),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminWorkCard(WorkData work) {
    return Dismissible(
      key: Key(work.id),
      direction: DismissDirection.horizontal,
      background: _buildDismissBackground(Colors.blue, Icons.edit, Alignment.centerLeft),
      secondaryBackground: _buildDismissBackground(Colors.red, Icons.delete, Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Editar trabajo
          return false;
        } else {
          // Eliminar trabajo
          return await _showDeleteWorkConfirmation(work);
        }
      },
      child: ModernCard(
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: const Color(0xFF3498db).withOpacity(0.1),
                child: work.image.isNotEmpty
                    ? Image.network(
                        work.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Color(0xFF3498db),
                            size: 32,
                          );
                        },
                      )
                    : const Icon(
                        Icons.car_repair,
                        color: Color(0xFF3498db),
                        size: 32,
                      ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    work.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    work.description,
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
                      color: _getCategoryColor(work.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      work.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(work.category),
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
                    // Editar trabajo
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
                  onPressed: () async {
                    if (await _showDeleteWorkConfirmation(work)) {
                      // Eliminar trabajo
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

  Widget _buildEmptyWorksState() {
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
              Icons.photo_library_outlined,
              size: 60,
              color: Color(0xFF3498db),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay trabajos disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega algunos trabajos para mostrar',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'detailing':
        return const Color(0xFF3498db);
      case 'restauración':
        return const Color(0xFFf39c12);
      case 'mecánica':
        return const Color(0xFF27ae60);
      default:
        return const Color(0xFF7f8c8d);
    }
  }

  void _showWorkDetail(WorkData work) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Imagen principal
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF3498db).withOpacity(0.1),
                ),
                child: work.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          work.image,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.car_repair,
                        size: 100,
                        color: Color(0xFF3498db),
                      ),
              ),
            ),
            
            // Información
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      work.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(work.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        work.category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(work.category),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      work.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7f8c8d),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteWorkConfirmation(WorkData work) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Trabajo'),
        content: Text('¿Estás seguro de que deseas eliminar "${work.name}"?'),
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

  List<WorkData> _getSimulatedWorks() {
    return [
      WorkData(
        id: '1',
        name: 'Detailing Renault Duster',
        description: 'Limpieza profunda y encerado completo de Renault Duster 2022. Incluye lavado interior, tratamiento de cueros y protección cerámica.',
        category: 'Detailing',
        image: '',
      ),
      WorkData(
        id: '2',
        name: 'Restauración MINI Cooper',
        description: 'Restauración completa de MINI Cooper Works. Pintura, detailing premium y modificaciones personalizadas.',
        category: 'Restauración',
        image: '',
      ),
      WorkData(
        id: '3',
        name: 'Protección Cerámica BMW',
        description: 'Aplicación de protección cerámica premium en BMW Serie 3. Duración de 3 años con garantía.',
        category: 'Detailing',
        image: '',
      ),
    ];
  }
}

class WorkData {
  final String id;
  final String name;
  final String description;
  final String category;
  final String image;

  WorkData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.image,
  });
}
