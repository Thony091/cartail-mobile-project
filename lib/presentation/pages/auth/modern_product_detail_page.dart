import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../shared/widgets/widgets.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernProductDetailPage extends ConsumerStatefulWidget {
  final String productId;
  static const name = 'ModernProductDetailPage';
  
  const ModernProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  ModernProductDetailPageState createState() => ModernProductDetailPageState();
}

class ModernProductDetailPageState extends ConsumerState<ModernProductDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  
  bool _isEditMode = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String _selectedCategory = 'Productos de Limpieza';
  List<String> _selectedImages = [];
  int _quantity = 1;
  
  final List<String> _categories = [
    'Productos de Limpieza',
    'Accesorios',
    'Herramientas',
    'Repuestos',
    'Ceras y Pulimentos',
    'Limpieza Interior',
  ];

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  void _loadProduct() async {
    if (widget.productId == 'new') {
      setState(() {
        _isEditMode = true;
        _isLoading = false;
      });
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Simular carga
    await Future.delayed(const Duration(milliseconds: 500));
    
    _nameController.text = 'Cera Premium para Auto';
    _descriptionController.text = 'Cera profesional de alta calidad para protección y brillo duradero. Fórmula avanzada con carnauba brasileña que proporciona protección UV y repelencia al agua.';
    _priceController.text = '25000';
    _stockController.text = '15';
    _skuController.text = 'WAX-PREM-001';
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.userData?.isAdmin ?? false;
    // final isAdmin = true; // Simular admin
    final isNewProduct = widget.productId == 'new';
    final stock = int.tryParse(_stockController.text) ?? 0;
    final isLowStock = stock > 0 && stock < 10;
    final isOutOfStock = stock == 0;

    return ModernScaffoldWithDrawer(
      title: isNewProduct 
          ? 'Nuevo Producto' 
          : _isEditMode 
              ? 'Editar Producto' 
              : 'Detalles del Producto',
      appBarActions: [
        if (!isNewProduct && isAdmin && !_isEditMode)
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
                      // Imagen del producto
                      FadeInDown(child: _buildProductImage()),
                      
                      const SizedBox(height: 24),
                      
                      // Info básica
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildBasicInfo(isOutOfStock, isLowStock),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Descripción
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildDescription(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Detalles
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _buildProductDetails(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Categoría
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildCategorySelector(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Botones
                      if (_isEditMode)
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: _buildActionButtons(isNewProduct),
                        )
                      else if (!isAdmin && !isOutOfStock)
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

  Widget _buildProductImage() {
    return ModernCard(
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF3498db).withOpacity(0.1),
        ),
        child: _selectedImages.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2, size: 80, color: Color(0xFF3498db)),
                  const SizedBox(height: 16),
                  if (_isEditMode)
                    TextButton.icon(
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Agregar Imagen'),
                      onPressed: _pickImage,
                    ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      _selectedImages.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
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
                        onPressed: _pickImage,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildBasicInfo(bool isOutOfStock, bool isLowStock) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditMode) ...[
              ModernInputField(
                label: 'Nombre del Producto',
                hint: 'Ej: Cera Premium para Auto',
                controller: _nameController,
                validator: (value) => value?.isEmpty ?? true ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'SKU',
                hint: 'Código del producto',
                controller: _skuController,
                prefixIcon: const Icon(Icons.qr_code),
              ),
            ] else ...[
              Text(
                _nameController.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'SKU: ${_skuController.text}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              
              // Badge de disponibilidad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? const Color(0xFFe74c3c).withOpacity(0.1)
                      : isLowStock
                          ? const Color(0xFFf39c12).withOpacity(0.1)
                          : const Color(0xFF27ae60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOutOfStock ? Icons.cancel : isLowStock ? Icons.warning : Icons.check_circle,
                      size: 16,
                      color: isOutOfStock
                          ? const Color(0xFFe74c3c)
                          : isLowStock
                              ? const Color(0xFFf39c12)
                              : const Color(0xFF27ae60),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOutOfStock ? 'Agotado' : isLowStock ? 'Pocas Unidades' : 'Disponible',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isOutOfStock
                            ? const Color(0xFFe74c3c)
                            : isLowStock
                                ? const Color(0xFFf39c12)
                                : const Color(0xFF27ae60),
                      ),
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

  Widget _buildDescription() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Color(0xFF3498db), size: 20),
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
                label: 'Descripción del Producto',
                hint: 'Describe las características...',
                controller: _descriptionController,
                maxLines: 6,
                validator: (value) => value?.isEmpty ?? true ? 'Ingresa una descripción' : null,
              )
            else
              Text(
                _descriptionController.text,
                style: const TextStyle(fontSize: 15, color: Color(0xFF2c3e50), height: 1.6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF3498db), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Detalles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Precio
            if (_isEditMode)
              ModernInputField(
                label: 'Precio (CLP)',
                hint: '25000',
                controller: _priceController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa un precio';
                  if (int.tryParse(value!) == null) return 'Precio inválido';
                  return null;
                },
              )
            else
              _buildDetailRow('Precio', '\$${_priceController.text}', Icons.attach_money, const Color(0xFF27ae60)),
            
            const SizedBox(height: 16),
            
            // Stock
            if (_isEditMode)
              ModernInputField(
                label: 'Stock',
                hint: '15',
                controller: _stockController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.inventory),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa el stock';
                  if (int.tryParse(value!) == null) return 'Stock inválido';
                  return null;
                },
              )
            else
              _buildDetailRow('Stock', '${_stockController.text} unidades', Icons.inventory, const Color(0xFF3498db)),
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
                Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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
            
            if (_isEditMode)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _selectedCategory = category),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF3498db).withOpacity(0.2),
                  );
                }).toList(),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498db).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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

  Widget _buildActionButtons(bool isNewProduct) {
    return Column(
      children: [
        ModernButton(
          text: _isSaving ? 'Guardando...' : (isNewProduct ? 'Crear Producto' : 'Guardar Cambios'),
          icon: _isSaving ? null : Icons.save,
          onPressed: _isSaving ? null : _saveProduct,
          isLoading: _isSaving,
        ),
        if (!isNewProduct) ...[
          const SizedBox(height: 12),
          ModernButton(
            text: 'Eliminar Producto',
            style: ModernButtonStyle.danger,
            icon: Icons.delete,
            onPressed: _deleteProduct,
          ),
        ],
      ],
    );
  }

  Widget _buildUserActions() {
    return Column(
      children: [
        // Selector de cantidad
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498db).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3498db),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        ModernButton(
          text: 'Agregar al Carrito',
          icon: Icons.shopping_cart,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$_quantity x ${_nameController.text} agregado al carrito'),
                backgroundColor: const Color(0xFF27ae60),
              ),
            );
          },
        ),
      ],
    );
  }

  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selector de imagen próximamente')),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.productId == 'new' ? 'Producto creado' : 'Cambios guardados'),
            backgroundColor: const Color(0xFF27ae60),
          ),
        );
        
        if (widget.productId == 'new') {
          context.pop();
        } else {
          setState(() => _isEditMode = false);
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
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
        const SnackBar(content: Text('Producto eliminado'), backgroundColor: Color(0xFFe74c3c)),
      );
      context.pop();
    }
  }
}