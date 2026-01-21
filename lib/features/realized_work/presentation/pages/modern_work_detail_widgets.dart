import 'package:flutter/material.dart';

import '../../../shared/presentation/shared/widgets/widgets.dart';

class WorkPhotoGallery extends StatelessWidget {
  final List<String> selectedImages;
  final bool isEditMode;
  final VoidCallback onPickImages;

  const WorkPhotoGallery({
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
          // Foto principal
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: const Color(0xFF9b59b6).withOpacity(0.1),
            ),
            child: selectedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.photo_camera,
                        size: 80,
                        color: Color(0xFF9b59b6),
                      ),
                      const SizedBox(height: 16),
                      if (isEditMode)
                        TextButton.icon(
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Agregar Fotos'),
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
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF9b59b6),
                                ),
                                onPressed: onPickImages,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),

          // Galería de miniaturas
          if (selectedImages.length > 1)
            Container(
              height: 100,
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: index == 0
                            ? const Color(0xFF9b59b6)
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

class WorkMainInfo extends StatelessWidget {
  final bool isEditMode;
  final TextEditingController titleController;
  final TextEditingController vehicleController;
  final bool isFeatured;
  final ValueChanged<bool?>? onFeaturedChanged;

  const WorkMainInfo({
    super.key,
    required this.isEditMode,
    required this.titleController,
    required this.vehicleController,
    required this.isFeatured,
    this.onFeaturedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditMode) ...[
              ModernInputField(
                label: 'Título del Trabajo',
                hint: 'Ej: Renault Duster Detailing',
                controller: titleController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Vehículo',
                hint: 'Ej: Renault Duster 2019',
                controller: vehicleController,
                prefixIcon: const Icon(Icons.directions_car),
              ),
            ] else ...[
              Text(
                titleController.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 20,
                    color: Color(0xFF7f8c8d),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vehicleController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7f8c8d),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Toggle destacado (solo en modo edición)
            if (isEditMode)
              CheckboxListTile(
                value: isFeatured,
                onChanged: onFeaturedChanged,
                title: const Text('Marcar como destacado'),
                subtitle: const Text('Aparecerá en la sección principal'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              )
            else if (isFeatured)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFf39c12).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: Color(0xFFf39c12)),
                    SizedBox(width: 6),
                    Text(
                      'Destacado',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFf39c12),
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

class WorkDescription extends StatelessWidget {
  final bool isEditMode;
  final TextEditingController descriptionController;

  const WorkDescription({
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
                  color: Color(0xFF9b59b6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Descripción del Trabajo',
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
                label: 'Descripción',
                hint: 'Describe los trabajos realizados...',
                controller: descriptionController,
                maxLines: 6,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingresa una descripción' : null,
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

class WorkAdditionalDetails extends StatelessWidget {
  final bool isEditMode;
  final DateTime completedDate;
  final VoidCallback onDateTap;

  const WorkAdditionalDetails({
    super.key,
    required this.isEditMode,
    required this.completedDate,
    required this.onDateTap,
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
                  color: Color(0xFF9b59b6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Información Adicional',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fecha
            if (isEditMode)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF9b59b6),
                ),
                title: const Text('Fecha de Realización'),
                subtitle: Text(_formatDate(completedDate)),
                onTap: onDateTap,
              )
            else
              WorkDetailRow(
                label: 'Fecha de Realización',
                value: _formatDate(completedDate),
                icon: Icons.calendar_today,
                color: const Color(0xFF9b59b6),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} ${date.year}';
  }
}

class WorkDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const WorkDetailRow({
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
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Column(
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkActionButtons extends StatelessWidget {
  final bool isNewWork;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  const WorkActionButtons({
    super.key,
    required this.isNewWork,
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
              : (isNewWork ? 'Crear Trabajo' : 'Guardar Cambios'),
          icon: isSaving ? null : Icons.save,
          onPressed: isSaving ? null : onSave,
          isLoading: isSaving,
        ),
        if (!isNewWork) ...[
          const SizedBox(height: 12),
          ModernButton(
            text: 'Eliminar Trabajo',
            style: ModernButtonStyle.danger,
            icon: Icons.delete,
            onPressed: onDelete,
          ),
        ],
      ],
    );
  }
}
