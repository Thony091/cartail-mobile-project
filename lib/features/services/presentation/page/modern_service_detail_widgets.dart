import 'package:flutter/material.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_button.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_card.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_input_field.dart';

class ServiceImageGallery extends StatelessWidget {
  final List<String> selectedImages;
  final bool isEditMode;
  final VoidCallback onPickImages;

  const ServiceImageGallery({
    super.key,
    required this.selectedImages,
    required this.isEditMode,
    required this.onPickImages,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        children: [
          // Imagen principal
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: const Color(0xFF3498db).withOpacity(0.1),
            ),
            child: selectedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: Color(0xFF3498db),
                      ),
                      const SizedBox(height: 16),
                      if (isEditMode)
                        TextButton.icon(
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Agregar Imágenes'),
                          onPressed: onPickImages,
                        ),
                    ],
                  )
                : Stack(
                    children: [
                      Image.network(
                        selectedImages.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      if (isEditMode)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF3498db),
                            ),
                            onPressed: onPickImages,
                          ),
                        ),
                    ],
                  ),
          ),

          // Miniaturas
          if (selectedImages.length > 1)
            Container(
              height: 80,
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: index == 0
                            ? const Color(0xFF3498db)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        selectedImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ServiceBasicInfo extends StatelessWidget {
  final bool isEditMode;
  final TextEditingController nameController;

  const ServiceBasicInfo({
    super.key,
    required this.isEditMode,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditMode)
              ModernInputField(
                label: 'Nombre del Servicio',
                hint: 'Ej: Detailing Premium',
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27ae60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF27ae60),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Disponible',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF27ae60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ServiceDescription extends StatelessWidget {
  final bool isEditMode;
  final TextEditingController descriptionController;

  const ServiceDescription({
    super.key,
    required this.isEditMode,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.description,
                  color: Color(0xFF3498db),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isEditMode)
              ModernInputField(
                label: 'Descripción del Servicio',
                hint: 'Describe los detalles del servicio...',
                controller: descriptionController,
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              )
            else
              Text(
                descriptionController.text,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2c3e50),
                  height: 1.6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ServiceDetailsSection extends StatelessWidget {
  final bool isEditMode;
  final TextEditingController priceController;
  final TextEditingController durationController;

  const ServiceDetailsSection({
    super.key,
    required this.isEditMode,
    required this.priceController,
    required this.durationController,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF3498db),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Detalles del Servicio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Precio
            if (isEditMode)
              ModernInputField(
                label: 'Precio (CLP)',
                hint: 'Ej: 120000',
                controller: priceController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un precio';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              )
            else
              ServiceDetailRow(
                label: 'Precio',
                value: '\$${priceController.text}',
                icon: Icons.attach_money,
                color: const Color(0xFF27ae60),
              ),

            const SizedBox(height: 16),

            // Duración
            if (isEditMode)
              ModernInputField(
                label: 'Duración (minutos)',
                hint: 'Ej: 180',
                controller: durationController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.schedule),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la duración';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingresa una duración válida';
                  }
                  return null;
                },
              )
            else
              ServiceDetailRow(
                label: 'Duración',
                value: '${durationController.text} min',
                icon: Icons.schedule,
                color: const Color(0xFF3498db),
              ),
          ],
        ),
      ),
    );
  }
}

class ServiceDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ServiceDetailRow({
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  final bool isEditMode;
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.isEditMode,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: Color(0xFF3498db), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Categoría',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isEditMode)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      onCategorySelected(category);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF3498db).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF3498db)
                          : const Color(0xFF7f8c8d),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF3498db)
                          : Colors.grey[300]!,
                    ),
                  );
                }).toList(),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498db).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3498db).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  selectedCategory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3498db),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ServiceActionButtons extends StatelessWidget {
  final bool isNewService;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  const ServiceActionButtons({
    super.key,
    required this.isNewService,
    required this.isSaving,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ModernButton(
          text: isSaving
              ? 'Guardando...'
              : (isNewService ? 'Crear Servicio' : 'Guardar Cambios'),
          icon: isSaving ? null : Icons.save,
          onPressed: isSaving ? null : onSave,
          isLoading: isSaving,
        ),
        if (!isNewService) ...[
          const SizedBox(height: 12),
          ModernButton(
            text: 'Eliminar Servicio',
            style: ModernButtonStyle.danger,
            icon: Icons.delete,
            onPressed: onDelete,
          ),
        ],
      ],
    );
  }
}

class ServiceUserActions extends StatelessWidget {
  final VoidCallback onReserve;
  final VoidCallback onAddToCart;

  const ServiceUserActions({
    super.key,
    required this.onReserve,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ModernButton(
          text: 'Reservar Servicio',
          icon: Icons.event_available,
          onPressed: onReserve,
        ),
        const SizedBox(height: 12),
        ModernButton(
          text: 'Agregar al Carrito',
          style: ModernButtonStyle.secondary,
          icon: Icons.shopping_cart,
          onPressed: onAddToCart,
        ),
      ],
    );
  }
}
