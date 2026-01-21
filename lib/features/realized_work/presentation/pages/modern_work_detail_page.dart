import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:portafolio_project/features/realized_work/presentation/pages/modern_work_detail_widgets.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';

class ModernWorkDetailPage extends ConsumerStatefulWidget {
  final String workId;
  static const name = 'ModernWorkDetailPage';

  const ModernWorkDetailPage({super.key, required this.workId});

  @override
  ModernWorkDetailPageState createState() => ModernWorkDetailPageState();
}

class ModernWorkDetailPageState extends ConsumerState<ModernWorkDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _vehicleController = TextEditingController();

  bool _isEditMode = false;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isFeatured = false;
  List<String> _selectedImages = [];
  DateTime _completedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadWork();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  void _loadWork() async {
    if (widget.workId == 'new') {
      setState(() {
        _isEditMode = true;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    // Simular carga
    await Future.delayed(const Duration(milliseconds: 500));

    _titleController.text = 'Renault Duster Detailing Premium';
    _descriptionController.text =
        'Transformación completa de Renault Duster con servicio de detailing premium. Se realizó lavado profundo, pulido de carrocería, tratamiento de cuero interior y encerado profesional.';
    _vehicleController.text = 'Renault Duster 2019';
    _isFeatured = true;

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.userData?.isAdmin ?? false;
    // final isAdmin = true; // Simular admin
    final isNewWork = widget.workId == 'new';

    return ModernScaffoldWithDrawer(
      title: isNewWork
          ? 'Nuevo Trabajo'
          : _isEditMode
          ? 'Editar Trabajo'
          : 'Detalles del Trabajo',
      appBarActions: [
        if (!isNewWork && isAdmin && !_isEditMode)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => setState(() => _isEditMode = true),
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
                      // Galería de fotos
                      FadeInDown(
                        child: WorkPhotoGallery(
                          selectedImages: _selectedImages,
                          isEditMode: _isEditMode,
                          onPickImages: _pickImages,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Información principal
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: WorkMainInfo(
                          isEditMode: _isEditMode,
                          titleController: _titleController,
                          vehicleController: _vehicleController,
                          isFeatured: _isFeatured,
                          onFeaturedChanged: (value) =>
                              setState(() => _isFeatured = value!),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Descripción
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: WorkDescription(
                          isEditMode: _isEditMode,
                          descriptionController: _descriptionController,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Detalles adicionales
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: WorkAdditionalDetails(
                          isEditMode: _isEditMode,
                          completedDate: _completedDate,
                          onDateTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _completedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _completedDate = date);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botones
                      if (_isEditMode)
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: WorkActionButtons(
                            isNewWork: isNewWork,
                            isSaving: _isSaving,
                            onSave: _saveWork,
                            onDelete: _deleteWork,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selector de imágenes próximamente')),
    );
  }

  Future<void> _saveWork() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.workId == 'new' ? 'Trabajo creado' : 'Cambios guardados',
            ),
            backgroundColor: const Color(0xFF27ae60),
          ),
        );

        if (widget.workId == 'new') {
          context.pop();
        } else {
          setState(() => _isEditMode = false);
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteWork() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Trabajo'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trabajo eliminado'),
          backgroundColor: Color(0xFFe74c3c),
        ),
      );
      context.pop();
    }
  }
}
