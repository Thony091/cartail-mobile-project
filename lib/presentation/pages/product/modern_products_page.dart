import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../shared/widgets/modern_button.dart';
import '../../shared/widgets/modern_card.dart';
import '../../shared/widgets/modern_input_field.dart';
import '../auth/modern_scaffold_with_drawer.dart';

class ModernProductsPage extends ConsumerStatefulWidget {
  static const name = 'ModernProductsPage';
  
  const ModernProductsPage({super.key});

  @override
  ModernProductsPageState createState() => ModernProductsPageState();
}

class ModernProductsPageState extends ConsumerState<ModernProductsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  String _sortBy = 'Recientes';
  
  final List<String> _categories = [
    'Todos',
    'Accesorios',
    'Cuidado Exterior',
    'Cuidado Interior',
    'Herramientas',
    'Neumáticos',
  ];
  
  final List<String> _sortOptions = [
    'Recientes',
    'Precio: Menor a Mayor',
    'Precio: Mayor a Menor',
    'Más Vendidos',
  ];

  @override
  Widget build(BuildContext context) {
    // final productsState = ref.watch(productsProvider);
    final List<ProductData> products = _getFilteredProducts();

    return ModernScaffoldWithDrawer(
      title: 'Productos',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterDialog,
        ),
      ],
      body: Container(
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
        child: CustomScrollView(
          slivers: [
            // Header con filtros
            SliverToBoxAdapter(
              child: _buildHeaderSection(),
            ),
            
            // Grid de productos
            if (products.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 50),
                      child: _buildProductCard(product),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filtros de categoría
          FadeInRight(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF3498db).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF3498db),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF3498db) : const Color(0xFF7f8c8d),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildProductCard(ProductData product) {
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(product.category),
                      _getCategoryColor(product.category).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(product.category),
                  size: 60,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            SizedBox( height: 5,),
            
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
                      color: _getCategoryColor(product.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(product.category),
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
                        onTap: product.stock > 0 ? () => _addToCart(product) : null,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: product.stock > 0
                                ? const LinearGradient(
                                    colors: [Color(0xFF3498db), Color(0xFF2980b9)],
                                  )
                                : null,
                            color: product.stock == 0 ? const Color(0xFFe2e8f0) : null,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: product.stock > 0
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF3498db).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            product.stock > 0 ? Icons.add_shopping_cart : Icons.block,
                            size: 20,
                            color: product.stock > 0 ? Colors.white : const Color(0xFF7f8c8d),
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

  Widget _buildEmptyState() {
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
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Buscar Producto'),
        content: ModernInputField(
          hint: 'Nombre del producto...',
          prefixIcon: const Icon(Icons.search),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          ModernButton(
            text: 'Cerrar',
            style: ModernButtonStyle.secondary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Ordenar Por'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sortOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _sortBy,
              activeColor: const Color(0xFF3498db),
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showProductDetails(ProductData product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                            _getCategoryColor(product.category),
                            _getCategoryColor(product.category).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(product.category),
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
                        color: _getCategoryColor(product.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(product.category),
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
                          color: product.stock > 0 ? const Color(0xFF27ae60) : const Color(0xFFe74c3c),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.stock > 0 ? '${product.stock} en stock' : 'Sin stock',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: product.stock > 0 ? const Color(0xFF27ae60) : const Color(0xFFe74c3c),
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
                        style: product.stock > 0 ? ModernButtonStyle.primary : ModernButtonStyle.secondary,
                        onPressed: product.stock > 0 ? () {
                          Navigator.pop(context);
                          _addToCart(product);
                        } : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(ProductData product) {
    // Agregar al carrito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        backgroundColor: const Color(0xFF27ae60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
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

  IconData _getCategoryIcon(String category) {
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

  List<ProductData> _getFilteredProducts() {
    List<ProductData> allProducts = _getSimulatedProducts();
    
    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      allProducts = allProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Filtrar por categoría
    if (_selectedCategory != 'Todos') {
      allProducts = allProducts.where((product) {
        return product.category == _selectedCategory;
      }).toList();
    }
    
    // Ordenar
    switch (_sortBy) {
      case 'Precio: Menor a Mayor':
        allProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Precio: Mayor a Menor':
        allProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Más Vendidos':
        // Simular ordenamiento por ventas
        break;
      case 'Recientes':
      default:
        // Ya viene ordenado por recientes
        break;
    }
    
    return allProducts;
  }

  List<ProductData> _getSimulatedProducts() {
    return [
      ProductData(
        id: '1',
        name: 'Cera Premium',
        description: 'Cera de alta calidad para protección y brillo duradero',
        price: 15990,
        stock: 25,
        category: 'Cuidado Exterior',
      ),
      ProductData(
        id: '2',
        name: 'Shampoo Auto',
        description: 'Shampoo especial para lavado de vehículos, pH neutro',
        price: 8990,
        stock: 50,
        category: 'Cuidado Exterior',
      ),
      ProductData(
        id: '3',
        name: 'Limpiador de Interiores',
        description: 'Limpiador multiusos para tablero, plásticos y tapicería',
        price: 12990,
        stock: 30,
        category: 'Cuidado Interior',
      ),
      ProductData(
        id: '4',
        name: 'Ambientador',
        description: 'Ambientador de larga duración con aroma a vainilla',
        price: 3990,
        stock: 100,
        category: 'Accesorios',
      ),
      ProductData(
        id: '5',
        name: 'Kit de Herramientas',
        description: 'Set completo de herramientas para detailing profesional',
        price: 45990,
        stock: 5,
        category: 'Herramientas',
      ),
      ProductData(
        id: '6',
        name: 'Paños Microfibra (Pack 3)',
        description: 'Pack de 3 paños de microfibra de alta absorción',
        price: 7990,
        stock: 40,
        category: 'Accesorios',
      ),
      ProductData(
        id: '7',
        name: 'Neumático 195/55R16',
        description: 'Neumático de alto rendimiento para ciudad',
        price: 89990,
        stock: 0,
        category: 'Neumáticos',
      ),
      ProductData(
        id: '8',
        name: 'Aspiradora Portátil',
        description: 'Aspiradora compacta de 12V para uso en vehículos',
        price: 34990,
        stock: 8,
        category: 'Herramientas',
      ),
    ];
  }
}

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