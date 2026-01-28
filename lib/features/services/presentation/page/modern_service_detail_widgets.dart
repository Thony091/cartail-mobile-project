import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/services/domain/entities/services.dart';
import 'package:portafolio_project/features/services/presentation/providers/service_form_provider.dart';
import 'package:portafolio_project/features/category/presentation/providers/categories_provider.dart';
import 'package:portafolio_project/features/services/presentation/providers/services_provider.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_button.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/services/camera/camera_gallery_service_impl.dart';

class ServiceImageGallery extends ConsumerWidget {
  final Services service;
  final bool isEditMode;

  const ServiceImageGallery({
    super.key,
    required this.service,
    required this.isEditMode,
  });

  Future<void> _pickImage(
    WidgetRef ref, {
    required bool useCamera,
  }) async {
    final cameraService = CameraGalleryServiceImpl();
    final photoPath = useCamera
        ? await cameraService.takePhoto()
        : await cameraService.selectPhoto();
    if (photoPath == null) return;

    ref.read(serviceFormProvider(service).notifier).updateServiceImage(photoPath);
  }

  Widget _buildImageWidget(String imagePath) {
    if (imagePath.trim().isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
      );
    }

    // Verificar si es una URL o una ruta local
    final isUrl = imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isUrl) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error al cargar: ${imagePath.substring(0, 50)}...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Ruta local
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 64, color: Colors.grey),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Archivo no encontrado: $imagePath',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final size = MediaQuery.of(context).size;

    // Obtener imágenes del formulario
    final selectedImages = ref.watch(
      serviceFormProvider(service).select((state) => state.images),
    );

    // Fallback a imágenes del servicio si el formulario está vacío
    // Esto asegura que las imágenes de la base de datos se muestren
    final imagesToDisplay = selectedImages.isNotEmpty
        ? selectedImages
        : service.images;

    final displayImages = imagesToDisplay
        .where((image) => image.trim().isNotEmpty)
        .toList();
    return ModernCard(
      child: Column(
        children: [
          // Imagen principal
          Container(
            height: size.height * 0.3,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              gradient: displayImages.isEmpty
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF667eea).withValues(alpha: 0.1),
                      const Color(0xFF764ba2).withValues(alpha: 0.1),
                    ],
                  )
                : null,
            ),
            child: displayImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 55,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isEditMode) ...[
                        const Text(
                          'Agregar Imagen del Servicio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Toca para seleccionar una imagen',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ref, useCamera: false),
                          icon: const Icon(
                            Icons.cloud_upload_outlined, 
                            size: 20
                          ),
                          label: const Text('Seleccionar Imagen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ref, useCamera: true),
                          icon: const Icon(
                            Icons.camera_alt_outlined, 
                            size: 20
                          ),
                          label: const Text('Tomar Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27ae60),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: _buildImageWidget(displayImages.first),
                      ),
                      // Overlay gradient para mejor lectura de los botones
                      if (isEditMode)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (isEditMode)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _pickImage(ref, useCamera: false),
                                borderRadius: BorderRadius.circular(12),
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Color(0xFF667eea),
                                        size: 20,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Cambiar',
                                        style: TextStyle(
                                          color: Color(0xFF667eea),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (isEditMode)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _pickImage(ref, useCamera: true),
                                borderRadius: BorderRadius.circular(12),
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: Color(0xFF27ae60),
                                        size: 20,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Foto',
                                        style: TextStyle(
                                          color: Color(0xFF27ae60),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),

          // Miniaturas
          if (displayImages.length > 1)
            Container(
              height: 80,
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayImages.length,
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
                      child: _buildImageWidget(displayImages[index]),
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

class ServiceBasicInfo extends ConsumerWidget {
  final String serviceId;
  final Services service;
  final bool isEditMode;


  const ServiceBasicInfo({
    super.key,
    required this.serviceId,
    required this.service,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceForm = ref.watch( serviceFormProvider( service ) );
    final serviceFormNotifier = ref.read( serviceFormProvider( service ).notifier );
    
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditMode)
              TextFormField(
                onChanged: serviceFormNotifier.onNameChange,
                initialValue: serviceForm.name.value.isEmpty
                    ? null
                    : serviceForm.name.value,
                decoration: InputDecoration(
                  labelText: 'Nombre del Servicio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF667eea),
                      width: 2,
                    ),
                  ),
                ),
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
                    serviceForm.name.value,
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
                      color: const Color(0xFF27ae60).withValues(alpha: 0.1),
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

class ServiceDescription extends ConsumerWidget {
  final bool isEditMode;
  final String serviceId;
  final Services service;

  const ServiceDescription({
    super.key,
    required this.isEditMode,
    required this.serviceId,
    required this.service,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceForm = ref.watch( serviceFormProvider( service ) );
    final serviceFormNotifier = ref.read( serviceFormProvider( service ).notifier );
    
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.description,
                  color: Color(0xFF3498db),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
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
              TextFormField(
                onChanged: serviceFormNotifier.onDescriptionChange,
                maxLines: 6,
                initialValue: serviceForm.description.value.isEmpty
                    ? null
                    : serviceForm.description.value,
                decoration: InputDecoration(
                  errorText: serviceForm.description.errorMessage,
                  labelText: 'Descripción del Servicio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF667eea),
                      width: 2,
                    ),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              )
            else
              Text(
                serviceForm.description.value,
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

class ServiceDetailsSection extends ConsumerWidget {
  final bool isEditMode;
  final String serviceId;
  final Services service;

  const ServiceDetailsSection({
    super.key,
    required this.serviceId,
    required this.service,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceForm = ref.watch( serviceFormProvider( service ) );
    final serviceFormNotifier = ref.read( serviceFormProvider( service ).notifier );
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF3498db),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
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

            // Precios (Mínimo y Máximo)
            if (isEditMode)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null) return;
                        serviceFormNotifier.onMinPriceChange(parsed);
                      },
                      keyboardType: TextInputType.number,
                      initialValue: serviceForm.minPrice.value == 0
                          ? null
                          : serviceForm.minPrice.value.toString(),
                      decoration: InputDecoration(
                        labelText: 'Precio Mínimo (CLP)',
                        prefixIcon: const Icon(Icons.attach_money),
                        errorText: serviceForm.minPrice.errorMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF667eea),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null) return;
                        serviceFormNotifier.onMaxPriceChange(parsed);
                      },
                      keyboardType: TextInputType.number,
                      initialValue: serviceForm.maxPrice.value == 0
                          ? null
                          : serviceForm.maxPrice.value.toString(),
                      decoration: InputDecoration(
                        labelText: 'Precio Máximo (CLP)',
                        errorText: serviceForm.maxPrice.errorMessage,
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF667eea),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              ServiceDetailRow(
                label: 'Precio',
                value: serviceForm.minPrice == serviceForm.maxPrice
                    ? '\$${serviceForm.minPrice.value}'
                    : '\$${serviceForm.minPrice.value} - \$${serviceForm.maxPrice.value}',
                icon: Icons.attach_money,
                color: const Color(0xFF27ae60),
              ),

            const SizedBox(height: 16),

            // Duración (opcional)
            if (isEditMode)
              TextFormField(
                onChanged: (value) {
                  if (value.trim().isEmpty) {
                    serviceFormNotifier.onDurationChange(0);
                    return;
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null) return;
                  serviceFormNotifier.onDurationChange(parsed);
                },
                keyboardType: TextInputType.number,
                initialValue: serviceForm.durationMinutes == 0
                    ? null
                    : serviceForm.durationMinutes.toString(),
                decoration: InputDecoration(
                  labelText: 'Duración (minutos) - Opcional',
                  prefixIcon: const Icon(Icons.schedule),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF667eea),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (int.tryParse(value) == null) {
                      return 'Número inválido';
                    }
                  }
                  return null;
                },
              )
            else if (serviceForm.durationMinutes != 0)
              ServiceDetailRow(
                label: 'Duración',
                value: '${serviceForm.durationMinutes} min',
                icon: Icons.schedule,
                color: const Color(0xFF3498db),
              ),

            if (isEditMode) ...[
              const SizedBox(height: 20),
              // Requiere Reserva
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Requiere reserva',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: serviceForm.requiresReservation,
                      onChanged: (value) => serviceFormNotifier.onRequiresReservationChange(value),
                      activeThumbColor: const Color(0xFF3498db),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Activo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Servicio activo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: serviceForm.isActive,
                      onChanged: (value) => serviceFormNotifier.onIsActiveChange(value),
                      activeThumbColor: const Color(0xFF27ae60),
                    ),
                  ],
                ),
              ),
            ],
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
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

class CategorySelector extends ConsumerWidget {
  final bool isEditMode;
  final String serviceId;
  final Services service;

  const CategorySelector({
    super.key,
    required this.isEditMode,
    required this.serviceId,
    required this.service,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceForm = ref.watch( serviceFormProvider( service ) );
    final serviceFormNotifier = ref.read( serviceFormProvider( service ).notifier );

    // Obtener las categorías activas del provider
    final categoriesState = ref.watch(categoriesProvider);
    final categories = ref.watch( activeCategoriesProvider );
    final selectedCategory = serviceForm.selectedCategory;
    final categoryError = serviceForm.categoryError;

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.category, color: Color(0xFF3498db), size: 20),
                SizedBox(width: 8),
                Text(
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
              if (categoriesState.loading)
                const Center(child: CircularProgressIndicator())
              else if (categories.isEmpty)
                Text(
                  'No hay categorías disponibles',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = selectedCategory == category.name;
                        return FilterChip(
                          label: Text(category.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            serviceFormNotifier.onCategoryChange(category.name);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF3498db).withValues(alpha: 0.2),
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
                    ),
                    if (categoryError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          categoryError,
                          style: const TextStyle(
                            color: Color(0xFFE74C3C),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498db).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3498db).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  selectedCategory.isEmpty ? 'Sin categoría' : selectedCategory,
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

class ServiceActionButtons extends ConsumerWidget {
  final String serviceId;
  final Services service;

  const ServiceActionButtons({
    super.key,
    required this.serviceId,
    required this.service,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceForm = ref.watch( serviceFormProvider( service ) );
    final serviceFormNotifier = ref.read( serviceFormProvider( service ).notifier );
    final isNewService = serviceId == 'new';

    return Column(
      children: [
        ModernButton(
          text: serviceForm.isLoading
            ? 'Guardando...'
            : isNewService 
              ? 'Crear Servicio' 
              : 'Guardar Cambios',
          icon: serviceForm.isLoading 
            ? null 
            : Icons.save,
          onPressed: serviceForm.isLoading 
            ? null 
            : () async => await serviceFormNotifier.onFormSubmit().then( (success) async{
                if (success) {
                  await Future.delayed(const Duration(milliseconds: 350));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isNewService
                          ? 'Servicio creado exitosamente'
                          : 'Cambios guardados exitosamente',
                      ),
                      backgroundColor: const Color(0xFF2ecc71),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              }),
          isLoading: serviceForm.isLoading,
        ),
        if (!isNewService) ...[
          const SizedBox(height: 12),
          ModernButton(
            text: 'Eliminar Servicio',
            style: ModernButtonStyle.danger,
            icon: Icons.delete,
            onPressed:() async => await ref.read( servicesProvider.notifier ).deleteService(serviceId),
          ),
        ],
      ],
    );
  }
}

class ServiceUserActions extends StatelessWidget {
  final VoidCallback onReserve;
  // final VoidCallback onAddToCart;

  const ServiceUserActions({
    super.key,
    required this.onReserve,
    // required this.onAddToCart,
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
        // const SizedBox(height: 12),
        // ModernButton(
        //   text: 'Agregar al Carrito',
        //   style: ModernButtonStyle.secondary,
        //   icon: Icons.shopping_cart,
        //   onPressed: onAddToCart,
        // ),
      ],
    );
  }
}
