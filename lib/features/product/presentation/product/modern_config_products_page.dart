import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:portafolio_project/features/product/presentation/product/modern_config_products_widgets.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';

import '../../../shared/presentation/shared/widgets/modern_floating_action_button.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';

class ModernConfigProductsPage extends ConsumerStatefulWidget {
  static const name = 'ModernConfigProductsPage';

  const ModernConfigProductsPage({super.key});

  @override
  ModernConfigProductsPageState createState() =>
      ModernConfigProductsPageState();
}

class ModernConfigProductsPageState
    extends ConsumerState<ModernConfigProductsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  bool _showOnlyInStock = false;

  final List<String> _categories = [
    'Todos',
    'Productos de Limpieza',
    'Accesorios',
    'Herramientas',
    'Repuestos',
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
                child: ProductsHeader(
                  products: products,
                  showOnlyInStock: _showOnlyInStock,
                  onShowOnlyInStockChanged: (value) =>
                      setState(() => _showOnlyInStock = value!),
                ),
              ),

              // Lista de productos
              if (products.isEmpty)
                SliverFillRemaining(
                  child: EmptyProductsView(
                    onCreate: () => context.push('/product-edit/new'),
                  ),
                )
              else
                ProductsList(
                  products: _filterProducts(products),
                  onEdit: (product) =>
                      context.push('/product-edit/${product.id}'),
                  onDelete: (product) async =>
                      await _showDeleteConfirmation(product),
                  onTap: (product) => context.push('/product/${product.id}'),
                  onShowOptions: (product) => _showProductOptions(product),
                ),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            content: Text(
              '¿Estás seguro de que deseas eliminar "${product.name}"?',
            ),
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
        ) ??
        false;
  }

  Future<void> _refreshProducts() async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
    // ref.read(productsProvider.notifier).getProducts();
  }

  List<ProductData> _filterProducts(List<ProductData> products) {
    return products.where((product) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Todos' || product.category == _selectedCategory;
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
