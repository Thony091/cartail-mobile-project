import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../shared/presentation/shared/widgets/widgets.dart';
import '../../domain/entities/works.dart';

String getWorkCategory(Works work) {
  final name = work.name.toLowerCase();
  final description = work.description.toLowerCase();
  final source = '$name $description';

  if (source.contains('detail')) {
    return 'Detailing';
  }
  if (source.contains('restaur')) {
    return 'Restauración';
  }
  if (source.contains('mecan') ||
      source.contains('motor') ||
      source.contains('aceite')) {
    return 'Mecánica';
  }

  return 'General';
}

class WorkCategoryTabs extends StatelessWidget {
  final TabController tabController;

  const WorkCategoryTabs({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        controller: tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3498db), Color(0xFF2980b9)],
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
    );
  }
}

class WorksGrid extends StatelessWidget {
  final List<Works> works;
  final bool isAdmin;
  final Function(Works) onWorkTap;
  final Future<void> Function() onRefresh;
  final Future<bool> Function(Works) onDeleteConfirmation;

  const WorksGrid({
    super.key,
    required this.works,
    required this.isAdmin,
    required this.onWorkTap,
    required this.onRefresh,
    required this.onDeleteConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return const EmptyWorksState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
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
                ? AdminWorkCard(
                    work: work,
                    onDelete: () => onDeleteConfirmation(work),
                  )
                : UserWorkCard(work: work, onTap: () => onWorkTap(work)),
          );
        },
      ),
    );
  }
}

class UserWorkCard extends StatelessWidget {
  final Works work;
  final VoidCallback onTap;

  const UserWorkCard({super.key, required this.work, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ModernCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getCategoryColor(getWorkCategory(work))
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getWorkCategory(work),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: getCategoryColor(getWorkCategory(work)),
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
}

class AdminWorkCard extends StatelessWidget {
  final Works work;
  final VoidCallback onDelete;

  const AdminWorkCard({super.key, required this.work, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(work.id),
      direction: DismissDirection.horizontal,
      background: _buildDismissBackground(
        Colors.blue,
        Icons.edit,
        Alignment.centerLeft,
      ),
      secondaryBackground: _buildDismissBackground(
        Colors.red,
        Icons.delete,
        Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Editar trabajo
          return false;
        } else {
          onDelete();
        }
        return null;
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getCategoryColor(getWorkCategory(work))
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getWorkCategory(work),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: getCategoryColor(getWorkCategory(work)),
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
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissBackground(
    Color color,
    IconData icon,
    Alignment alignment,
  ) {
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
}

class EmptyWorksState extends StatelessWidget {
  const EmptyWorksState({super.key});

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
          ),
        ],
      ),
    );
  }
}

class WorkDetailSheet extends StatelessWidget {
  final Works work;

  const WorkDetailSheet({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      child: Image.network(work.image, fit: BoxFit.cover),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getCategoryColor(getWorkCategory(work))
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      getWorkCategory(work),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: getCategoryColor(getWorkCategory(work)),
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
    );
  }
}

Color getCategoryColor(String category) {
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
