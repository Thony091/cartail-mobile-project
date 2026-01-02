import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:portafolio_project/presentation/pages/auth/service/modern_service_detail_widgets.dart';

import 'package:portafolio_project/presentation/shared/widgets/modern_button.dart';
import '../../../providers/auth_provider.dart';
import '../modern_scaffold_with_drawer.dart';

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

    // Cargar servicio
    // final service = await ref.read(serviceProvider(widget.serviceId).future);

    // Simular carga
    await Future.delayed(const Duration(milliseconds: 500));

    // Llenar formulario con datos simulados
    _nameController.text = 'Detailing Premium';
    _descriptionController.text =
        'Servicio completo de detailing para tu vehículo. Incluye lavado exterior e interior, encerado, pulido de carrocería, limpieza de motor y tratamiento de llantas.';
    _priceController.text = '120000';
    _durationController.text = '180';
    _selectedCategory = 'Detailing';

    setState(() => _isLoading = false);
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
      // Guardar servicio
      // final serviceData = {
      //   'name': _nameController.text,
      //   'description': _descriptionController.text,
      //   'price': int.parse(_priceController.text),
      //   'duration': int.parse(_durationController.text),
      //   'category': _selectedCategory,
      //   'images': _selectedImages,
      // };

      // if (widget.serviceId == 'new') {
      //   await ref.read(servicesProvider.notifier).createService(serviceData);
      // } else {
      //   await ref.read(servicesProvider.notifier).updateService(widget.serviceId, serviceData);
      // }

      // Simular guardado
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
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
      // Eliminar servicio
      // await ref.read(servicesProvider.notifier).deleteService(widget.serviceId);

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
