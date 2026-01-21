import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:portafolio_project/features/services/presentation/page/modern_service_detail_widgets.dart';

import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../providers/service_provider.dart';
import '../providers/services_provider.dart';

class ModernServiceDetailPage extends ConsumerStatefulWidget {
  final String serviceId;
  static const name = 'ModernServiceDetailPage';

  const ModernServiceDetailPage({super.key, required this.serviceId});

  @override
  ModernServiceDetailPageState createState() => ModernServiceDetailPageState();
}

class ModernServiceDetailPageState
    extends ConsumerState<ModernServiceDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  bool _isEditMode = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String _selectedCategory = 'Detailing';
  List<String> _selectedImages = [];

  final List<String> _categories = [
    'Detailing',
    'Mecánica',
    'Pintura',
    'Neumáticos',
    'Eléctrica',
    'Carrocería',
  ];

  @override
  void initState() {
    super.initState();
    _loadService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _loadService() async {
    if (widget.serviceId == 'new') {
      setState(() {
        _isEditMode = true;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    ref.listen<ServiceState>(
      serviceProvider(widget.serviceId),
      (previous, next) {
        final service = next.service;
        if (service == null) {
          if (mounted) {
            setState(() => _isLoading = next.isLoading);
          }
          return;
        }

        _nameController.text = service.name;
        _descriptionController.text = service.description;
        _priceController.text = service.minPrice.toString();
        _durationController.text = '';
        _selectedImages = List<String>.from(service.images);

        if (mounted) {
          setState(() => _isLoading = next.isLoading);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.userData?.isAdmin ?? false;
    // final isAdmin = true; // Simular admin para testing
    final isNewService = widget.serviceId == 'new';

    return ModernScaffoldWithDrawer(
      title: isNewService
          ? 'Crear Servicio'
          : _isEditMode
          ? 'Editar Servicio'
          : 'Detalles del Servicio',
      appBarActions: [
        if (!isNewService && isAdmin && !_isEditMode)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => setState(() => _isEditMode = true),
          ),
        if (_isEditMode && !isNewService)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _isEditMode = false),
          ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Galería de imágenes
                      FadeInDown(
                        child: ServiceImageGallery(
                          selectedImages: _selectedImages,
                          isEditMode: _isEditMode,
                          onPickImages: _pickImages,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Información básica
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: ServiceBasicInfo(
                          isEditMode: _isEditMode,
                          nameController: _nameController,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Descripción
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: ServiceDescription(
                          isEditMode: _isEditMode,
                          descriptionController: _descriptionController,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Detalles del servicio
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: ServiceDetailsSection(
                          isEditMode: _isEditMode,
                          priceController: _priceController,
                          durationController: _durationController,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Categoría
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: CategorySelector(
                          isEditMode: _isEditMode,
                          selectedCategory: _selectedCategory,
                          categories: _categories,
                          onCategorySelected: (category) =>
                              setState(() => _selectedCategory = category),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botones de acción
                      if (_isEditMode)
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: ServiceActionButtons(
                            isNewService: isNewService,
                            isSaving: _isSaving,
                            onSave: _saveService,
                            onDelete: _deleteService,
                          ),
                        )
                      else if (!isAdmin)
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: ServiceUserActions(
                            onReserve: () {
                              context.push(
                                '/reservations?service=${widget.serviceId}',
                              );
                            },
                            onAddToCart: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Servicio agregado al carrito'),
                                  backgroundColor: Color(0xFF27ae60),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _pickImages() {
    // Implementar selector de imágenes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selector de imágenes próximamente'),
        backgroundColor: Color(0xFF3498db),
      ),
    );
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final price = int.tryParse(_priceController.text) ?? 0;
      final serviceData = {
        'id': widget.serviceId == 'new' ? null : widget.serviceId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'minPrice': price,
        'maxPrice': price,
        'isActive': true,
        'images': _selectedImages,
      };

      final saved = await ref
          .read(servicesProvider.notifier)
          .createOrUpdateService(serviceData);

      if (mounted) {
        if (!saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo guardar el servicio'),
              backgroundColor: Color(0xFFe74c3c),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.serviceId == 'new'
                  ? 'Servicio creado'
                  : 'Cambios guardados',
            ),
            backgroundColor: const Color(0xFF27ae60),
          ),
        );

        if (widget.serviceId == 'new') {
          context.pop();
        } else {
          setState(() => _isEditMode = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFe74c3c),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteService() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Servicio'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este servicio? Esta acción no se puede deshacer.',
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

    if (confirmed == true && mounted) {
      final deleted =
          await ref.read(servicesProvider.notifier).deleteService(
                widget.serviceId,
              );

      if (!deleted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo eliminar el servicio'),
            backgroundColor: Color(0xFFe74c3c),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servicio eliminado'),
          backgroundColor: Color(0xFFe74c3c),
        ),
      );

      context.pop();
    }
  }
}
