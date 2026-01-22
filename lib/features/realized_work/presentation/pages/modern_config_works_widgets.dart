import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../../domain/entities/works.dart';

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
                  value: totalWorks.toString(),
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
  final List<Works> works;
  final Function(Works) onWorkTap;

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
  final Works work;
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
                    image: work.image.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(work.image),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: work.image.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.photo_camera,
                            size: 50,
                            color: Color(0xFF3498db),
                          ),
                        )
                      : null,
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
                    work.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class WorkOptionsSheet extends StatelessWidget {
  final Works work;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WorkOptionsSheet({
    super.key,
    required this.work,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  work.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF3498db)),
            title: const Text('Editar'),
            onTap: onEdit,
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
            title: const Text('Eliminar'),
            onTap: onDelete,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

}

class SearchWorksDialog extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const SearchWorksDialog({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buscar Trabajo'),
      content: ModernInputField(
        label: 'Buscar',
        hint: 'Título del trabajo...',
        onChanged: onSearch,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class SortWorksDialog extends StatelessWidget {
  final String currentSort;
  final List<String> sortOptions;
  final ValueChanged<String> onSortChanged;

  const SortWorksDialog({
    super.key,
    required this.currentSort,
    required this.sortOptions,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ordenar por'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: sortOptions.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: currentSort,
            onChanged: (value) {
              if (value != null) {
                onSortChanged(value);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
