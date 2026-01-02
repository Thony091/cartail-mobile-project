import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/modern_button.dart';
import '../../../shared/widgets/modern_card.dart';

class WorkData {
  final String id;
  final String title;
  final String? imageUrl;
  final DateTime date;
  final bool isFeatured;

  final String description;
  final String vehicle;

  WorkData({
    required this.id,
    required this.title,
    required this.description,
    required this.vehicle,
    this.imageUrl,
    required this.date,
    this.isFeatured = false,
  });
}

class WorksHeader extends StatelessWidget {
  final int totalWorks;

  const WorksHeader({super.key, required this.totalWorks});

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Estadísticas
          Row(
            children: [
              Expanded(
                child: WorkStatCard(
                  label: 'Total',
                  value: totalWorks.toString(),
                  icon: Icons.photo_library,
                  color: const Color(0xFF9b59b6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WorkStatCard(
                  label: 'Este Mes',
                  value: '5',
                  icon: Icons.add_photo_alternate,
                  color: const Color(0xFF3498db),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const WorkStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
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
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class WorksGrid extends StatelessWidget {
  final List<WorkData> works;
  final Function(WorkData) onWorkTap;

  const WorksGrid({super.key, required this.works, required this.onWorkTap});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final work = works[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: WorkCard(work: work, onTap: () => onWorkTap(work)),
          );
        }, childCount: works.length),
      ),
    );
  }
}

class WorkCard extends StatelessWidget {
  final WorkData work;
  final VoidCallback onTap;

  const WorkCard({super.key, required this.work, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: InkWell(
        onTap: onTap,
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
                          Icon(Icons.star, size: 14, color: Colors.white),
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class EmptyWorksView extends StatelessWidget {
  final VoidCallback onCreateWork;

  const EmptyWorksView({super.key, required this.onCreateWork});

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
            style: TextStyle(fontSize: 16, color: Color(0xFF7f8c8d)),
          ),

          const SizedBox(height: 32),

          ModernButton(
            text: 'Crear Trabajo',
            icon: Icons.add,
            onPressed: onCreateWork,
          ),
        ],
      ),
    );
  }
}
