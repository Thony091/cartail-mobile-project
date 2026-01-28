import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/works.dart';
import '../providers/work_form_provider.dart';
import '../providers/work_provider.dart';
import '../providers/works_provider.dart';
import '../../../shared/presentation/shared/widgets/widgets.dart';
import '../../../shared/presentation/shared/services/camera/camera_gallery_service_impl.dart';

class WorkPhotoGallery extends ConsumerWidget {
  final Works work;
  final bool isEditMode;

  const WorkPhotoGallery({
    super.key,
    required this.work,
    required this.isEditMode,
  });

  Future<void> _pickImage(
    WidgetRef ref,
    BuildContext context, {
    required bool isBefore,
  }) async {
    final useCamera = await _selectImageSource(context);
    if (useCamera == null) return;

    final cameraService = CameraGalleryServiceImpl();
    final photoPath = useCamera
        ? await cameraService.takePhoto()
        : await cameraService.selectPhoto();
    if (photoPath == null) return;

    final notifier = ref.read(workFormProvider(work).notifier);
    if (isBefore) {
      notifier.updateBeforeImage(photoPath);
    } else {
      notifier.updateAfterImage(photoPath);
    }
  }

  Future<bool?> _selectImageSource(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: Color(0xFF667eea)),
                ),
                title: const Text('Seleccionar de galería'),
                onTap: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27ae60).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_camera, color: Color(0xFF27ae60)),
                ),
                title: const Text('Tomar foto'),
                onTap: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
          );
        },
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
          );
        },
      );
    }
    try {
      final bytes = base64Decode(path);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } catch (_) {
      return const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: Color(0xFF9b59b6),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(workFormProvider(work));
    final beforeImage = formState.beforeImage.value;
    final afterImage = formState.afterImage.value;

    return ModernCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _ImageSlot(
                    title: 'Antes',
                    imagePath: beforeImage,
                    isEditMode: isEditMode,
                    onPick: () => _pickImage(ref, context, isBefore: true),
                    buildImage: _buildImage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageSlot(
                    title: 'Después',
                    imagePath: afterImage,
                    isEditMode: isEditMode,
                    onPick: () => _pickImage(ref, context, isBefore: false),
                    buildImage: _buildImage,
                  ),
                ),
              ],
            ),
          ),
          if (beforeImage.isEmpty || afterImage.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Agrega imágenes de antes y después',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageSlot extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isEditMode;
  final VoidCallback onPick;
  final Widget Function(String) buildImage;

  const _ImageSlot({
    required this.title,
    required this.imagePath,
    required this.isEditMode,
    required this.onPick,
    required this.buildImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2c3e50),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF9b59b6).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            children: [
              if (imagePath.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: buildImage(imagePath),
                )
              else
                const Center(
                  child: Icon(
                    Icons.photo_camera,
                    size: 48,
                    color: Color(0xFF9b59b6),
                  ),
                ),
              if (isEditMode)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onPick,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class WorkBasicInfo extends ConsumerWidget {
  final String workId;
  final Works work;
  final bool isEditMode;

  const WorkBasicInfo({
    super.key,
    required this.workId,
    required this.work,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workForm = ref.watch(workFormProvider(work));
    final workFormNotifier = ref.read(workFormProvider(work).notifier);

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditMode)
              Column(
                children: [
                  ModernInputField(
                    label: 'Título del Trabajo',
                    hint: 'Ej: Renault Duster Detailing',
                    initialValue: workForm.title.value,
                    onChanged: workFormNotifier.onTitleChange,
                    errorMessage: workForm.titleError,
                  ),
                  const SizedBox(height: 16),
                  ModernInputField(
                    label: 'ID Modelo Vehículo',
                    hint: 'Ej: 1',
                    keyboardType: TextInputType.number,
                    initialValue: workForm.vehicleModelId.toString(),
                    onChanged: (value) =>
                        workFormNotifier.onVehicleModelIdChange(int.tryParse(value) ?? 1),
                    prefixIcon: const Icon(Icons.directions_car),
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    value: workForm.isFeatured,
                    onChanged: (value) =>
                        workFormNotifier.onIsFeaturedChange(value ?? false),
                    title: const Text('Marcar como destacado'),
                    subtitle: const Text('Aparecerá en la sección principal'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF667eea),
                  ),
                  CheckboxListTile(
                    value: workForm.isActive,
                    onChanged: (value) =>
                        workFormNotifier.onIsActiveChange(value ?? true),
                    title: const Text('Trabajo activo'),
                    subtitle: const Text('Visible para los usuarios'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF667eea),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workForm.title.value,
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
                        'Modelo ID: ${workForm.vehicleModelId}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (workForm.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf39c12).withValues(alpha: 0.1),
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
                      if (workForm.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27ae60).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Color(0xFF27ae60)),
                              SizedBox(width: 6),
                              Text(
                                'Activo',
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
          ],
        ),
      ),
    );
  }
}

class WorkDescription extends ConsumerWidget {
  final bool isEditMode;
  final String workId;
  final Works work;

  const WorkDescription({
    super.key,
    required this.isEditMode,
    required this.workId,
    required this.work,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workForm = ref.watch(workFormProvider(work));
    final workFormNotifier = ref.read(workFormProvider(work).notifier);

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.description,
                  color: Color(0xFF9b59b6),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
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
                initialValue: workForm.description.value,
                onChanged: workFormNotifier.onDescriptionChange,
                maxLines: 6,
                errorMessage: workForm.descriptionError,
              )
            else
              Text(
                workForm.description.value,
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

class WorkTestimonialAndRating extends ConsumerWidget {
  final bool isEditMode;
  final String workId;
  final Works work;

  const WorkTestimonialAndRating({
    super.key,
    required this.isEditMode,
    required this.workId,
    required this.work,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workForm = ref.watch(workFormProvider(work));
    final workFormNotifier = ref.read(workFormProvider(work).notifier);

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  color: Color(0xFF9b59b6),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Testimonio y Calificación',
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
                label: 'Testimonio',
                hint: 'Comentario del cliente',
                maxLines: 4,
                initialValue: workForm.testimonial.value,
                errorMessage: workForm.testimonialError,
                onChanged: workFormNotifier.onTestimonialChange,
              )
            else
              Text(
                workForm.testimonial.value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2c3e50),
                  height: 1.6,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFf1c40f)),
                const SizedBox(width: 8),
                Expanded(
                  child: isEditMode
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: workForm.rating,
                              isExpanded: true,
                              items: List.generate(
                                5,
                                (index) => DropdownMenuItem(
                                  value: index + 1,
                                  child: Text('${index + 1} estrellas'),
                                ),
                              ),
                              onChanged: (value) {
                                if (value == null) return;
                                workFormNotifier.onRatingChange(value);
                              },
                            ),
                          ),
                        )
                      : Text(
                          '${workForm.rating}/5',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2c3e50),
                          ),
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

class WorkDateSection extends ConsumerWidget {
  final bool isEditMode;
  final String workId;
  final Works work;

  const WorkDateSection({
    super.key,
    required this.isEditMode,
    required this.workId,
    required this.work,
  });

  String _formatDate(String value) {
    if (value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final datePart = parsed.toIso8601String().split('T').first;
    return datePart;
  }

  Future<void> _pickDate(
    BuildContext context,
    WorkFormNotifier notifier,
    String currentDate,
  ) async {
    final now = DateTime.now();
    final initialDate = DateTime.tryParse(currentDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    notifier.onDateChange(picked.toIso8601String());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workForm = ref.watch(workFormProvider(work));
    final workFormNotifier = ref.read(workFormProvider(work).notifier);
    final displayDate = _formatDate(workForm.date);

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Color(0xFF9b59b6),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Fecha del Trabajo',
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
                key: ValueKey(displayDate),
                label: 'Fecha',
                hint: 'Selecciona una fecha',
                initialValue: displayDate,
                readOnly: true,
                onTap: () => _pickDate(context, workFormNotifier, workForm.date),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Selecciona una fecha' : null,
                suffixIcon: const Icon(Icons.date_range),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF9b59b6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF9b59b6).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event,
                      size: 18,
                      color: Color(0xFF9b59b6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayDate,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2c3e50),
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

class WorkActionButtons extends ConsumerWidget {
  final String workId;
  final Works work;

  const WorkActionButtons({
    super.key,
    required this.workId,
    required this.work,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workForm = ref.watch(workFormProvider(work));
    final workFormNotifier = ref.read(workFormProvider(work).notifier);
    final isNewWork = workId == 'new';

    return Column(
      children: [
        ModernButton(
          text: workForm.isLoading
              ? 'Guardando...'
              : (isNewWork ? 'Crear Trabajo' : 'Guardar Cambios'),
          icon: workForm.isLoading ? null : Icons.save,
          onPressed: workForm.isLoading
              ? null
              : () async {
                  final success = await workFormNotifier.onFormSubmit();
                  if (!context.mounted) return;

                  if (!success) {
                    // Los errores de validación ya se muestran en los campos
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isNewWork ? 'Trabajo creado' : 'Cambios guardados',
                      ),
                      backgroundColor: const Color(0xFF27ae60),
                    ),
                  );

                  if (isNewWork) {
                    context.pop();
                  } else {
                    ref.read(workProvider(workId).notifier).setEditMode(false);
                  }
                },
          isLoading: workForm.isLoading,
        ),
        if (!isNewWork) ...[
          const SizedBox(height: 12),
          ModernButton(
            text: 'Eliminar Trabajo',
            style: ModernButtonStyle.danger,
            icon: Icons.delete,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Eliminar Trabajo'),
                  content: const Text(
                    '¿Estás seguro? Esta acción no se puede deshacer.',
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
              );

              if (confirmed != true || !context.mounted) return;

              await ref.read(worksProvider.notifier).deleteWork(work.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trabajo eliminado'),
                    backgroundColor: Color(0xFFe74c3c),
                  ),
                );
                context.pop();
              }
            },
          ),
        ],
      ],
    );
  }
}
