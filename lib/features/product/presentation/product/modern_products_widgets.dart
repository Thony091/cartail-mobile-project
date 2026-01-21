import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';

class ProductData {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;

  ProductData({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
  });
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Accesorios':
      return const Color(0xFF3498db);
    case 'Cuidado Exterior':
      return const Color(0xFF27ae60);
    case 'Cuidado Interior':
      return const Color(0xFFf39c12);
    case 'Herramientas':
      return const Color(0xFFe74c3c);
    case 'Neumáticos':
      return const Color(0xFF9b59b6);
    default:
      return const Color(0xFF7f8c8d);
  }
}

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Accesorios':
      return Icons.extension;
    case 'Cuidado Exterior':
      return Icons.local_car_wash;
    case 'Cuidado Interior':
      return Icons.cleaning_services;
    case 'Herramientas':
      return Icons.build;
    case 'Neumáticos':
      return Icons.tire_repair;
    default:
      return Icons.shopping_bag;
  }
}

class ProductHeaderSection extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;

  const ProductHeaderSection({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda
          FadeInLeft(
            child: ModernInputField(
              hint: 'Buscar productos...',
              prefixIcon: const Icon(Icons.search),
              onChanged: onSearchChanged,
            ),
          ),

          const SizedBox(height: 16),

          // Filtros de categoría
          FadeInRight(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) => onCategorySelected(category),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF3498db).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF3498db),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF3498db)
                            : const Color(0xFF7f8c8d),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      getCategoryColor(product.category),
                      getCategoryColor(product.category).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Icon(
                  getCategoryIcon(product.category),
                  size: 60,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.all(1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: getCategoryColor(
                        product.category,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: getCategoryColor(product.category),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Nombre del producto
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Descripción
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7f8c8d),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Precio y stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF27ae60),
                            ),
                          ),
                          if (product.stock < 10 && product.stock > 0)
                            Text(
                              '${product.stock} disponibles',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFf39c12),
                              ),
                            )
                          else if (product.stock == 0)
                            const Text(
                              'Sin stock',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFe74c3c),
                              ),
                            ),
                        ],
                      ),

                      // Botón de agregar al carrito
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: product.stock > 0
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF3498db),
                                      Color(0xFF2980b9),
                                    ],
                                  )
                                : null,
                            color: product.stock == 0
                                ? const Color(0xFFe2e8f0)
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: product.stock > 0
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF3498db,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            product.stock > 0
                                ? Icons.add_shopping_cart
                                : Icons.block,
                            size: 20,
                            color: product.stock > 0
                                ? Colors.white
                                : const Color(0xFF7f8c8d),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductEmptyState extends StatelessWidget {
  const ProductEmptyState({super.key});

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
              color: const Color(0xFF7f8c8d).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: Color(0xFF7f8c8d),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay productos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No se encontraron productos con los filtros aplicados',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
          ),
        ],
      ),
    );
  }
}

class SearchProductDialog extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const SearchProductDialog({super.key, required this.onSearch});

  @override
  State<SearchProductDialog> createState() => _SearchProductDialogState();
}

class _SearchProductDialogState extends State<SearchProductDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Buscar Producto'),
      content: ModernInputField(
        hint: 'Nombre del producto...',
        prefixIcon: const Icon(Icons.search),
        onChanged: (value) {
          _controller.text = value;
          widget.onSearch(value);
        },
      ),
      actions: [
        ModernButton(
          text: 'Cerrar',
          style: ModernButtonStyle.secondary,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class FilterProductDialog extends StatefulWidget {
  final List<String> sortOptions;
  final String currentSortBy;
  final ValueChanged<String> onSortChanged;

  const FilterProductDialog({
    super.key,
    required this.sortOptions,
    required this.currentSortBy,
    required this.onSortChanged,
  });

  @override
  State<FilterProductDialog> createState() => _FilterProductDialogState();
}

class _FilterProductDialogState extends State<FilterProductDialog> {
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.currentSortBy;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Ordenar Por'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.sortOptions.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _sortBy,
            activeColor: const Color(0xFF3498db),
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
              widget.onSortChanged(value!);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

class ProductDetailsSheet extends StatelessWidget {
  final ProductData product;
  final VoidCallback onAddToCart;

  const ProductDetailsSheet({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFe2e8f0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          getCategoryColor(product.category),
                          getCategoryColor(product.category).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        getCategoryIcon(product.category),
                        size: 100,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Categoría
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getCategoryColor(
                        product.category,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: getCategoryColor(product.category),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nombre
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Precio
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF27ae60),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stock
                  Row(
                    children: [
                      Icon(
                        product.stock > 0 ? Icons.check_circle : Icons.cancel,
                        color: product.stock > 0
                            ? const Color(0xFF27ae60)
                            : const Color(0xFFe74c3c),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.stock > 0
                            ? '${product.stock} en stock'
                            : 'Sin stock',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: product.stock > 0
                              ? const Color(0xFF27ae60)
                              : const Color(0xFFe74c3c),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7f8c8d),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botón de agregar al carrito
                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Agregar al Carrito',
                      icon: Icons.add_shopping_cart,
                      style: product.stock > 0
                          ? ModernButtonStyle.primary
                          : ModernButtonStyle.secondary,
                      onPressed: product.stock > 0
                          ? () {
                              onAddToCart();
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
