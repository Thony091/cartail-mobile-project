import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'modern_products_widgets.dart';

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
              child: ProductHeaderSection(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
            ),

            // Grid de productos
            if (products.isEmpty)
              const SliverFillRemaining(child: ProductEmptyState())
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
                      child: ProductCard(
                        product: product,
                        onTap: () => _showProductDetails(product),
                        onAddToCart: product.stock > 0
                            ? () => _addToCart(product)
                            : null,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => SearchProductDialog(
        onSearch: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterProductDialog(
        sortOptions: _sortOptions,
        currentSortBy: _sortBy,
        onSortChanged: (value) {
          setState(() {
            _sortBy = value;
          });
        },
      ),
    );
  }

  void _showProductDetails(ProductData product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailsSheet(
        product: product,
        onAddToCart: () {
          Navigator.pop(context);
          _addToCart(product);
        },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<ProductData> _getFilteredProducts() {
    List<ProductData> allProducts = _getSimulatedProducts();

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      allProducts = allProducts.where((product) {
        return product.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            product.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
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
