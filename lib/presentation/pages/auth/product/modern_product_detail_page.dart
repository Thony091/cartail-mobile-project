import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:portafolio_project/presentation/pages/auth/product/modern_product_detail_widgets.dart';

import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/modern_button.dart';
import '../modern_scaffold_with_drawer.dart';

class ModernProductDetailPage extends ConsumerStatefulWidget {
  final String productId;
  static const name = 'ModernProductDetailPage';

  const ModernProductDetailPage({super.key, required this.productId});

  @override
  ModernProductDetailPageState createState() => ModernProductDetailPageState();
}

class ModernProductDetailPageState
    extends ConsumerState<ModernProductDetailPage> {
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
    _descriptionController.text =
        'Cera profesional de alta calidad para protección y brillo duradero. Fórmula avanzada con carnauba brasileña que proporciona protección UV y repelencia al agua.';
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
                      FadeInDown(
                        child: ProductImageGallery(
                          selectedImages: _selectedImages,
                          isEditMode: _isEditMode,
                          onPickImage: _pickImage,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info básica
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: ProductBasicInfo(
                          isEditMode: _isEditMode,
                          isOutOfStock: isOutOfStock,
                          isLowStock: isLowStock,
                          nameController: _nameController,
                          skuController: _skuController,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Descripción
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: ProductDescription(
                          isEditMode: _isEditMode,
                          descriptionController: _descriptionController,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Detalles
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: ProductDetailsSection(
                          isEditMode: _isEditMode,
                          priceController: _priceController,
                          stockController: _stockController,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Categoría
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: ProductCategorySelector(
                          isEditMode: _isEditMode,
                          selectedCategory: _selectedCategory,
                          categories: _categories,
                          onCategorySelected: (category) =>
                              setState(() => _selectedCategory = category),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botones
                      if (_isEditMode)
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: ProductActionButtons(
                            isNewProduct: isNewProduct,
                            isSaving: _isSaving,
                            onSave: _saveProduct,
                            onDelete: _deleteProduct,
                          ),
                        )
                      else if (!isAdmin && !isOutOfStock)
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: ProductUserActions(
                            productName: _nameController.text,
                            quantity: _quantity,
                            onQuantityDecrease: () =>
                                setState(() => _quantity--),
                            onQuantityIncrease: () =>
                                setState(() => _quantity++),
                            onAddToCart: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$_quantity x ${_nameController.text} agregado al carrito',
                                  ),
                                  backgroundColor: const Color(0xFF27ae60),
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
            content: Text(
              widget.productId == 'new'
                  ? 'Producto creado'
                  : 'Cambios guardados',
            ),
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
        const SnackBar(
          content: Text('Producto eliminado'),
          backgroundColor: Color(0xFFe74c3c),
        ),
      );
      context.pop();
    }
  }
}
