import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:portafolio_project/features/home/views/components/stat_card_widget.dart';
import '../../../shared/presentation/shared/widgets/widgets.dart';
import '../../domain/entities/services.dart';

// Helper function to get service icons
IconData getServiceIcon(String category) {
  switch (category.toLowerCase()) {
    case 'detailing':
      return Icons.cleaning_services;
    case 'mecánica':
      return Icons.build;
    case 'pintura':
      return Icons.brush;
    case 'neumáticos':
      return Icons.circle_outlined;
    default:
      return Icons.car_repair;
  }
}

String getServiceCategory(Services service) {
  final name = service.name.toLowerCase();
  final description = service.description.toLowerCase();
  final source = '$name $description';

  if (source.contains('detail')) {
    return 'Detailing';
  }
  if (source.contains('mecan') ||
      source.contains('aceite') ||
      source.contains('motor') ||
      source.contains('filtro')) {
    return 'Mecánica';
  }
  if (source.contains('pint')) {
    return 'Pintura';
  }
  if (source.contains('neumatic') ||
      source.contains('llanta') ||
      source.contains('rueda')) {
    return 'Neumáticos';
  }

  return 'General';
}

class ServiceHeaderSection extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final int totalServices;
  final int activeServices;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;
  final bool showSearchBar;

  const ServiceHeaderSection({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.totalServices,
    required this.activeServices,
    required this.onSearchChanged,
    required this.onCategorySelected,
    this.showSearchBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          FadeInDown(
            child: Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    value: totalServices.toString(),
                    label: 'Servicios',
                    icon: Icons.build,
                    color: const Color(0xFF3498db),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCardWidget(
                    value: activeServices.toString(),
                    label: 'Activos',
                    icon: Icons.check_circle,
                    color: const Color(0xFF27ae60),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (showSearchBar) ...[
            // Search Bar
            FadeInLeft(
              child: ModernInputField(
                hint: 'Buscar servicios...',
                prefixIcon: const Icon(Icons.search),
                onChanged: onSearchChanged,
              ),
            ),

            const SizedBox(height: 16),
          ],

          // Category Filters
          FadeInRight(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) => onCategorySelected(category),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(
                        0xFF3498db,
                      ).withValues(alpha: .2),
                      checkmarkColor: const Color(0xFF3498db),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF3498db)
                            : const Color(0xFF7f8c8d),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchServicesDialog extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const SearchServicesDialog({super.key, required this.onSearch});

  @override
  State<SearchServicesDialog> createState() => _SearchServicesDialogState();
}

class _SearchServicesDialogState extends State<SearchServicesDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buscar Servicios'),
      content: ModernInputField(
        hint: 'Escribe el nombre del servicio...',
        // autofocus: true,
        onChanged: (value) {
          _controller.text = value;
          widget.onSearch(value);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ModernButton(
          text: 'Buscar',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class FilterServicesDialog extends StatelessWidget {
  final VoidCallback onApply;

  const FilterServicesDialog({super.key, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 20),
          // Aquí irían los filtros adicionales
          ModernButton(
            text: 'Aplicar Filtros',
            onPressed: () {
              onApply();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
