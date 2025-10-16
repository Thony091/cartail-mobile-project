
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/modern_button.dart';
import '../../shared/widgets/modern_card.dart';
import '../../shared/widgets/modern_floating_action_button.dart';
import '../../shared/widgets/modern_input_field.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernConfigProductsPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigProductsPage';
  
  const ModernConfigProductsPage({super.key});

  @override
  ModernConfigProductsPageState createState() => ModernConfigProductsPageState();
}

class ModernConfigProductsPageState extends ConsumerState<ModernConfigProductsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  bool _showOnlyInStock = false;
  
  final List<String> _categories = [
    'Todos', 'Productos de Limpieza', 'Accesorios', 'Herramientas', 'Repuestos'
  ];

  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar
    // ref.read(productsProvider.notifier).getProducts();
  }

  @override
  Widget build(BuildContext context) {
    // final productsState = ref.watch(productsProvider);
    
    // Datos simulados para el ejemplo - reemplazar con productsState.products
    final List<ProductData> products = _getSimulatedProducts();

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Productos',
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
        child: RefreshIndicator(
          onRefresh: _refreshProducts,
          child: CustomScrollView(
            slivers: [
              // Header con estadísticas
              SliverToBoxAdapter(
                child: _buildHeaderSection(products),
              ),
              
              // Lista de productos
              if (products.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                _buildProductsList(products),
            ],
          ),
        ),
      ),
      floatingActionButton: ModernFloatingActionButton(
        tooltip: 'Crear Producto',
        icon: Icons.add,
        onPressed: () => context.push('/product-edit/new'),
      ),
    );
  }

  Widget _buildHeaderSection(List<ProductData> products) {
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          
          // Estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  products.length.toString(),
                  Icons.inventory,
                  const Color(0xFF3498db),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'En Stock',
                  inStock.toString(),
                  Icons.check_circle,
                  const Color(0xFF27ae60),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Stock Bajo',
                  lowStock.toString(),
                  Icons.warning,
                  const Color(0xFFf39c12),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Toggle de filtro rápido
          CheckboxListTile(
            value: _showOnlyInStock,
            onChanged: (value) => setState(() => _showOnlyInStock = value!),
            title: const Text('Mostrar solo productos con stock'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<ProductData> products) {
    final filteredProducts = _filterProducts(products);
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = filteredProducts[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 50),
              child: _buildProductCard(product),
            );
          },
          childCount: filteredProducts.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductData product) {
    final bool isLowStock = product.stock > 0 && product.stock < 10;
    final bool isOutOfStock = product.stock == 0;
    
    return Dismissible(
      key: Key(product.id),
      background: _buildDismissBackground(
        color: const Color(0xFF3498db),
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildDismissBackground(
        color: const Color(0xFFe74c3c),
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Editar
          context.push('/product-edit/${product.id}');
          return false;
        } else {
          // Eliminar
          return await _showDeleteConfirmation(product);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ModernCard(
          child: InkWell(
            onTap: () => context.push('/product/${product.id}'),
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
                    onPressed: () => _showProductOptions(product),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
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
          child: Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
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
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7f8c8d),
            ),
          ),
          
          const SizedBox(height: 32),
          
          ModernButton(
            text: 'Crear Producto',
            icon: Icons.add,
            onPressed: () => context.push('/product-edit/new'),
          ),
        ],
      ),
    );
  }

  void _showProductOptions(ProductData product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product.stock} unidades',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.visibility, color: Color(0xFF3498db)),
              title: const Text('Ver detalles'),
              onTap: () {
                Navigator.pop(context);
                context.push('/product/${product.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF3498db)),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                context.push('/product-edit/${product.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Color(0xFF27ae60)),
              title: const Text('Actualizar Stock'),
              onTap: () {
                Navigator.pop(context);
                _showUpdateStockDialog(product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
              title: const Text('Eliminar'),
              onTap: () async {
                Navigator.pop(context);
                await _showDeleteConfirmation(product);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Producto'),
        content: ModernInputField(
          label: 'Buscar',
          hint: 'Nombre del producto...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _categories.map((category) {
            return RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUpdateStockDialog(ProductData product) {
    final controller = TextEditingController(text: product.stock.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Producto: ${product.name}'),
            const SizedBox(height: 16),
            ModernInputField(
              label: 'Cantidad en Stock',
              hint: 'Ingrese la cantidad',
              keyboardType: TextInputType.number,
              controller: controller,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ModernButton(
            text: 'Actualizar',
            onPressed: () {
              Navigator.pop(context);
              // Aquí actualizar el stock
              // ref.read(productsProvider.notifier).updateStock(product.id, int.parse(controller.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stock actualizado'),
                  backgroundColor: Color(0xFF27ae60),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(ProductData product) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que deseas eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ModernButton(
            text: 'Eliminar',
            style: ModernButtonStyle.danger,
            onPressed: () {
              Navigator.of(context).pop(true);
              // Aquí eliminar el producto
              // ref.read(productsProvider.notifier).deleteProduct(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto eliminado'),
                  backgroundColor: Color(0xFFe74c3c),
                ),
              );
            },
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _refreshProducts() async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
    // ref.read(productsProvider.notifier).getProducts();
  }

  List<ProductData> _filterProducts(List<ProductData> products) {
    return products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Todos' ||
          product.category == _selectedCategory;
      final matchesStock = !_showOnlyInStock || product.stock > 0;
      return matchesSearch && matchesCategory && matchesStock;
    }).toList();
  }

  List<ProductData> _getSimulatedProducts() {
    return [
      ProductData(
        id: '1',
        name: 'Cera Premium para Auto',
        category: 'Productos de Limpieza',
        price: 25000,
        stock: 15,
      ),
      ProductData(
        id: '2',
        name: 'Pulimento para Carrocería',
        category: 'Productos de Limpieza',
        price: 18000,
        stock: 5,
      ),
      ProductData(
        id: '3',
        name: 'Shampoo pH Neutro',
        category: 'Productos de Limpieza',
        price: 12000,
        stock: 0,
      ),
      ProductData(
        id: '4',
        name: 'Microfibra Premium',
        category: 'Accesorios',
        price: 8000,
        stock: 25,
      ),
      ProductData(
        id: '5',
        name: 'Aspiradora Portátil',
        category: 'Herramientas',
        price: 45000,
        stock: 3,
      ),
    ];
  }
}

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
