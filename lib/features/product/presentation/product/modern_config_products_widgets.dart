import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';

class ProductData {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? imageUrl;

  ProductData({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
  });
}

class ProductsHeader extends StatelessWidget {
  final List<ProductData> products;
  final bool showOnlyInStock;
  final Function(bool?) onShowOnlyInStockChanged;

  const ProductsHeader({
    super.key,
    required this.products,
    required this.showOnlyInStock,
    required this.onShowOnlyInStockChanged,
  });

  @override
  Widget build(BuildContext context) {
    final inStock = products.where((p) => p.stock > 0).length;
    final lowStock = products.where((p) => p.stock > 0 && p.stock < 10).length;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventario de Productos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona tu catálogo de productos',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Estadísticas
          Row(
            children: [
              Expanded(
                child: ProductStatCard(
                  label: 'Total',
                  value: products.length.toString(),
                  icon: Icons.inventory,
                  color: const Color(0xFF3498db),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProductStatCard(
                  label: 'En Stock',
                  value: inStock.toString(),
                  icon: Icons.check_circle,
                  color: const Color(0xFF27ae60),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProductStatCard(
                  label: 'Stock Bajo',
                  value: lowStock.toString(),
                  icon: Icons.warning,
                  color: const Color(0xFFf39c12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Toggle de filtro rápido
          CheckboxListTile(
            value: showOnlyInStock,
            onChanged: onShowOnlyInStockChanged,
            title: const Text('Mostrar solo productos con stock'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}

class ProductStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ProductStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class ProductsList extends StatelessWidget {
  final List<ProductData> products;
  final Function(ProductData) onEdit;
  final Future<bool> Function(ProductData) onDelete;
  final Function(ProductData) onTap;
  final Function(ProductData) onShowOptions;

  const ProductsList({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = products[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: ProductAdminCard(
              product: product,
              onEdit: () => onEdit(product),
              onDelete: () => onDelete(product),
              onTap: () => onTap(product),
              onShowOptions: () => onShowOptions(product),
            ),
          );
        }, childCount: products.length),
      ),
    );
  }
}

class ProductAdminCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback onEdit;
  final Future<bool> Function() onDelete;
  final VoidCallback onTap;
  final VoidCallback onShowOptions;

  const ProductAdminCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = product.stock > 0 && product.stock < 10;
    final bool isOutOfStock = product.stock == 0;

    return Dismissible(
      key: Key(product.id),
      background: const DismissBackground(
        color: Color(0xFF3498db),
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: const DismissBackground(
        color: Color(0xFFe74c3c),
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Editar
          onEdit();
          return false;
        } else {
          // Eliminar
          return await onDelete();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ModernCard(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Imagen del producto
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF3498db).withOpacity(0.1),
                    ),
                    child: product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2,
                            color: Color(0xFF3498db),
                            size: 40,
                          ),
                  ),

                  const SizedBox(width: 16),

                  // Información del producto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2c3e50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Badge de stock
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
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
                                    size: 14,
                                    color: isOutOfStock
                                        ? const Color(0xFFe74c3c)
                                        : isLowStock
                                        ? const Color(0xFFf39c12)
                                        : const Color(0xFF27ae60),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isOutOfStock
                                        ? 'Sin Stock'
                                        : isLowStock
                                        ? 'Stock Bajo (${product.stock})'
                                        : 'Stock: ${product.stock}',
                                    style: TextStyle(
                                      fontSize: 12,
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
                            const Spacer(),
                            Text(
                              '\$${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3498db),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botón de más opciones
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: onShowOptions,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyProductsView extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyProductsView({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Color(0xFF3498db),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'No hay productos registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Comienza agregando productos a tu inventario',
            style: TextStyle(fontSize: 16, color: Color(0xFF7f8c8d)),
          ),

          const SizedBox(height: 32),

          ModernButton(
            text: 'Crear Producto',
            icon: Icons.add,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

class DismissBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;

  const DismissBackground({
    super.key,
    required this.color,
    required this.icon,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
