
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../shared/shared.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernServiceDetailPage extends ConsumerStatefulWidget {
  final String serviceId;
  static const name = 'ModernServiceDetailPage';
  
  const ModernServiceDetailPage({
    super.key,
    required this.serviceId,
  });

  @override
  ModernServiceDetailPageState createState() => ModernServiceDetailPageState();
}

class ModernServiceDetailPageState extends ConsumerState<ModernServiceDetailPage> {
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
    _descriptionController.text = 'Servicio completo de detailing para tu vehículo. Incluye lavado exterior e interior, encerado, pulido de carrocería, limpieza de motor y tratamiento de llantas.';
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
                        child: _buildImageGallery(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Información básica
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildBasicInfo(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Descripción
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildDescription(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Detalles del servicio
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _buildServiceDetails(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Categoría
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildCategorySelector(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Botones de acción
                      if (_isEditMode)
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: _buildActionButtons(isNewService),
                        )
                      else if (!isAdmin)
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: _buildUserActions(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildImageGallery() {
    return ModernCard(
      child: Column(
        children: [
          // Imagen principal
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: const Color(0xFF3498db).withOpacity(0.1),
            ),
            child: _selectedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: Color(0xFF3498db),
                      ),
                      const SizedBox(height: 16),
                      if (_isEditMode)
                        TextButton.icon(
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Agregar Imágenes'),
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
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF3498db),
                            ),
                            onPressed: _pickImages,
                          ),
                        ),
                    ],
                  ),
          ),
          
          // Miniaturas
          if (_selectedImages.length > 1)
            Container(
              height: 80,
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
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
                        _selectedImages[index],
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

  Widget _buildBasicInfo() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditMode)
              ModernInputField(
                label: 'Nombre del Servicio',
                hint: 'Ej: Detailing Premium',
                controller: _nameController,
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
                    _nameController.text,
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

  Widget _buildDescription() {
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
            if (_isEditMode)
              ModernInputField(
                label: 'Descripción del Servicio',
                hint: 'Describe los detalles del servicio...',
                controller: _descriptionController,
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

  Widget _buildServiceDetails() {
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
            if (_isEditMode)
              ModernInputField(
                label: 'Precio (CLP)',
                hint: 'Ej: 120000',
                controller: _priceController,
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
              _buildDetailRow(
                'Precio',
                '\$${_priceController.text}',
                Icons.attach_money,
                const Color(0xFF27ae60),
              ),
            
            const SizedBox(height: 16),
            
            // Duración
            if (_isEditMode)
              ModernInputField(
                label: 'Duración (minutos)',
                hint: 'Ej: 180',
                controller: _durationController,
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
              _buildDetailRow(
                'Duración',
                '${_durationController.text} min',
                Icons.schedule,
                const Color(0xFF3498db),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
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

  Widget _buildCategorySelector() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.category,
                  color: Color(0xFF3498db),
                  size: 20,
                ),
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
            
            if (_isEditMode)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF3498db).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF3498db) : const Color(0xFF7f8c8d),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF3498db) : Colors.grey[300]!,
                    ),
                  );
                }).toList(),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498db).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3498db).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _selectedCategory,
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

  Widget _buildActionButtons(bool isNewService) {
    return Column(
      children: [
        ModernButton(
          text: _isSaving ? 'Guardando...' : (isNewService ? 'Crear Servicio' : 'Guardar Cambios'),
          icon: _isSaving ? null : Icons.save,
          onPressed: _isSaving ? null : _saveService,
          isLoading: _isSaving,
        ),
        if (!isNewService) ...[
          const SizedBox(height: 12),
          ModernButton(
            text: 'Eliminar Servicio',
            style: ModernButtonStyle.danger,
            icon: Icons.delete,
            onPressed: _deleteService,
          ),
        ],
      ],
    );
  }

  Widget _buildUserActions() {
    return Column(
      children: [
        ModernButton(
          text: 'Reservar Servicio',
          icon: Icons.event_available,
          onPressed: () {
            // Navegar a reserva
            context.push('/reservations?service=${widget.serviceId}');
          },
        ),
        const SizedBox(height: 12),
        ModernButton(
          text: 'Agregar al Carrito',
          style: ModernButtonStyle.secondary,
          icon: Icons.shopping_cart,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Servicio agregado al carrito'),
                backgroundColor: Color(0xFF27ae60),
              ),
            );
          },
        ),
      ],
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
            content: Text(widget.serviceId == 'new' ? 'Servicio creado' : 'Cambios guardados'),
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
        content: const Text('¿Estás seguro de que deseas eliminar este servicio? Esta acción no se puede deshacer.'),
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






