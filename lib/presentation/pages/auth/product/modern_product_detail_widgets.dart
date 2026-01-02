import 'package:flutter/material.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_button.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_card.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_input_field.dart';

class ProductImageGallery extends StatelessWidget {
  final List<String> selectedImages;
  final bool isEditMode;
  final VoidCallback onPickImage;

  const ProductImageGallery({
    super.key,
    required this.selectedImages,
    required this.isEditMode,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF3498db).withOpacity(0.1),
        ),
        child: selectedImages.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2,
                    size: 80,
                    color: Color(0xFF3498db),
                  ),
                  const SizedBox(height: 16),
                  if (isEditMode)
                    TextButton.icon(
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Agregar Imagen'),
                      onPressed: onPickImage,
                    ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      selectedImages.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  if (isEditMode)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF3498db),
                        ),
                        onPressed: onPickImage,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class ProductBasicInfo extends StatelessWidget {
  final bool isEditMode;
  final bool isOutOfStock;
  final bool isLowStock;
  final TextEditingController nameController;
  final TextEditingController skuController;

  const ProductBasicInfo({
    super.key,
    required this.isEditMode,
    required this.isOutOfStock,
    required this.isLowStock,
    required this.nameController,
    required this.skuController,
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
                label: 'Nombre del Producto',
                hint: 'Ej: Cera Premium para Auto',
                controller: nameController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'SKU',
                hint: 'Código del producto',
                controller: skuController,
                prefixIcon: const Icon(Icons.qr_code),
              ),
            ] else ...[
              Text(
                nameController.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'SKU: ${skuController.text}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),

              // Badge de disponibilidad
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                      isOutOfStock
                          ? Icons.cancel
                          : isLowStock
                          ? Icons.warning
                          : Icons.check_circle,
                      size: 16,
                      color: isOutOfStock
                          ? const Color(0xFFe74c3c)
                          : isLowStock
                          ? const Color(0xFFf39c12)
                          : const Color(0xFF27ae60),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOutOfStock
                          ? 'Agotado'
                          : isLowStock
                          ? 'Pocas Unidades'
                          : 'Disponible',
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
}

class ProductDescription extends StatelessWidget {
  final bool isEditMode;
  final TextEditingController descriptionController;

  const ProductDescription({
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

            if (isEditMode)
              ModernInputField(
                label: 'Descripción del Producto',
                hint: 'Describe las características...',
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

class ProductDetailsSection extends StatelessWidget {
  final bool isEditMode;
  final TextEditingController priceController;
  final TextEditingController stockController;

  const ProductDetailsSection({
    super.key,
    required this.isEditMode,
    required this.priceController,
    required this.stockController,
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
                  color: Color(0xFF3498db),
                  size: 20,
                ),
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
            if (isEditMode)
              ModernInputField(
                label: 'Precio (CLP)',
                hint: '25000',
                controller: priceController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa un precio';
                  if (int.tryParse(value!) == null) return 'Precio inválido';
                  return null;
                },
              )
            else
              ProductDetailRow(
                label: 'Precio',
                value: '\$${priceController.text}',
                icon: Icons.attach_money,
                color: const Color(0xFF27ae60),
              ),

            const SizedBox(height: 16),

            // Stock
            if (isEditMode)
              ModernInputField(
                label: 'Stock',
                hint: '15',
                controller: stockController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.inventory),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa el stock';
                  if (int.tryParse(value!) == null) return 'Stock inválido';
                  return null;
                },
              )
            else
              ProductDetailRow(
                label: 'Stock',
                value: '${stockController.text} unidades',
                icon: Icons.inventory,
                color: const Color(0xFF3498db),
              ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ProductDetailRow({
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

class ProductCategorySelector extends StatelessWidget {
  final bool isEditMode;
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategorySelected;

  const ProductCategorySelector({
    super.key,
    required this.isEditMode,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
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

            if (isEditMode)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) => onCategorySelected(category),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF3498db).withOpacity(0.2),
                  );
                }).toList(),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498db).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedCategory,
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

class ProductActionButtons extends StatelessWidget {
  final bool isNewProduct;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  const ProductActionButtons({
    super.key,
    required this.isNewProduct,
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
              : (isNewProduct ? 'Crear Producto' : 'Guardar Cambios'),
          icon: isSaving ? null : Icons.save,
          onPressed: isSaving ? null : onSave,
          isLoading: isSaving,
        ),
        if (!isNewProduct) ...[
          const SizedBox(height: 12),
          ModernButton(
            text: 'Eliminar Producto',
            style: ModernButtonStyle.danger,
            icon: Icons.delete,
            onPressed: onDelete,
          ),
        ],
      ],
    );
  }
}

class ProductUserActions extends StatelessWidget {
  final String productName;
  final int quantity;
  final VoidCallback onQuantityDecrease;
  final VoidCallback onQuantityIncrease;
  final VoidCallback onAddToCart;

  const ProductUserActions({
    super.key,
    required this.productName,
    required this.quantity,
    required this.onQuantityDecrease,
    required this.onQuantityIncrease,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
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
                onPressed: quantity > 1 ? onQuantityDecrease : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498db).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3498db),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onQuantityIncrease,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ModernButton(
          text: 'Agregar al Carrito',
          icon: Icons.shopping_cart,
          onPressed: onAddToCart,
        ),
      ],
    );
  }
}
