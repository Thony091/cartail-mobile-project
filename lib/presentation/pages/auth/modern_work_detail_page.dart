import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../shared/widgets/widgets.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernWorkDetailPage extends ConsumerStatefulWidget {
  final String workId;
  static const name = 'ModernWorkDetailPage';
  
  const ModernWorkDetailPage({
    super.key,
    required this.workId,
  });

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
    _descriptionController.text = 'Transformación completa de Renault Duster con servicio de detailing premium. Se realizó lavado profundo, pulido de carrocería, tratamiento de cuero interior y encerado profesional.';
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
                      FadeInDown(child: _buildPhotoGallery()),
                      
                      const SizedBox(height: 24),
                      
                      // Información principal
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildMainInfo(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Descripción
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildDescription(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Detalles adicionales
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _buildAdditionalDetails(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Botones
                      if (_isEditMode)
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: _buildActionButtons(isNewWork),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPhotoGallery() {
    return ModernCard(
      child: Column(
        children: [
          // Foto principal
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: const Color(0xFF9b59b6).withOpacity(0.1),
            ),
            child: _selectedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_camera, size: 80, color: Color(0xFF9b59b6)),
                      const SizedBox(height: 16),
                      if (_isEditMode)
                        TextButton.icon(
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Agregar Fotos'),
                          onPressed: _pickImages,
                        ),
                    ],
                  )
                : Stack(
                    children: [
                      Image.network(
                        _selectedImages.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      if (_isEditMode)
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
                                onPressed: _pickImages,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          
          // Galería de miniaturas
          if (_selectedImages.length > 1)
            Container(
              height: 100,
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: index == 0 ? const Color(0xFF9b59b6) : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(_selectedImages[index], fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditMode) ...[
              ModernInputField(
                label: 'Título del Trabajo',
                hint: 'Ej: Renault Duster Detailing',
                controller: _titleController,
                validator: (value) => value?.isEmpty ?? true ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Vehículo',
                hint: 'Ej: Renault Duster 2019',
                controller: _vehicleController,
                prefixIcon: const Icon(Icons.directions_car),
              ),
            ] else ...[
              Text(
                _titleController.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 20, color: Color(0xFF7f8c8d)),
                  const SizedBox(width: 8),
                  Text(
                    _vehicleController.text,
                    style: const TextStyle(fontSize: 16, color: Color(0xFF7f8c8d)),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Toggle destacado (solo en modo edición)
            if (_isEditMode)
              CheckboxListTile(
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value!),
                title: const Text('Marcar como destacado'),
                subtitle: const Text('Aparecerá en la sección principal'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              )
            else if (_isFeatured)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildDescription() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Color(0xFF9b59b6), size: 20),
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
            
            if (_isEditMode)
              ModernInputField(
                label: 'Descripción',
                hint: 'Describe los trabajos realizados...',
                controller: _descriptionController,
                maxLines: 6,
                validator: (value) => value?.isEmpty ?? true ? 'Ingresa una descripción' : null,
              )
            else
              Text(
                _descriptionController.text,
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

  Widget _buildAdditionalDetails() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF9b59b6), size: 20),
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
            if (_isEditMode)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Color(0xFF9b59b6)),
                title: const Text('Fecha de Realización'),
                subtitle: Text(_formatDate(_completedDate)),
                onTap: () async {
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
              )
            else
              _buildDetailRow(
                'Fecha de Realización',
                _formatDate(_completedDate),
                Icons.calendar_today,
                const Color(0xFF9b59b6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
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
              Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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

  Widget _buildActionButtons(bool isNewWork) {
    return Column(
      children: [
        ModernButton(
          text: _isSaving ? 'Guardando...' : (isNewWork ? 'Crear Trabajo' : 'Guardar Cambios'),
          icon: _isSaving ? null : Icons.save,
          onPressed: _isSaving ? null : _saveWork,
          isLoading: _isSaving,
        ),
        if (!isNewWork) ...[
          const SizedBox(height: 12),
          ModernButton(
            text: 'Eliminar Trabajo',
            style: ModernButtonStyle.danger,
            icon: Icons.delete,
            onPressed: _deleteWork,
          ),
        ],
      ],
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
            content: Text(widget.workId == 'new' ? 'Trabajo creado' : 'Cambios guardados'),
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

  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} ${date.year}';
  }
}






