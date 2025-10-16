import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_scaffold_with_drawer.dart';

import '../../presentation_container.dart';

class ModernCartPage extends ConsumerStatefulWidget {
  static const name = 'ModernCartPage';
  
  const ModernCartPage({super.key});

  @override
  ModernCartPageState createState() => ModernCartPageState();
}

class ModernCartPageState extends ConsumerState<ModernCartPage> {
  @override
  Widget build(BuildContext context) {
    // final cartState = ref.watch(cartProvider);
    List<CartItem> cartItems = _getSimulatedCartItems();
    final double total = _calculateTotal(cartItems);

    return ModernScaffoldWithDrawer(
      title: 'Mi Carrito',
      body: cartItems.isEmpty 
          ? _buildEmptyCart()
          : Column(
              children: [
                // Lista de items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      CartItem item = cartItems[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 100),
                        child: _buildCartItem(item, index),
                      );
                    },
                  ),
                ),
                
                // Footer con total y checkout
                _buildCartFooter(total),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
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
              Icons.shopping_cart_outlined,
              size: 60,
              color: Color(0xFF3498db),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Agrega algunos productos',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7f8c8d),
            ),
          ),
          
          const SizedBox(height: 32),
          
          ModernButton(
            text: 'Explorar Servicios',
            icon: Icons.explore,
            onPressed: () {
              // Navegar a servicios
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFe74c3c),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        onDismissed: (direction) {
          setState(() {
            // Remover item del carrito
          });
        },
        child: ModernCard(
          child: Row(
            children: [
              // Imagen del servicio/producto
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFF3498db).withOpacity(0.1),
                  child: const Icon(
                    Icons.car_repair,
                    color: Color(0xFF3498db),
                    size: 32,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información del item
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7f8c8d),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      item.price.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF27ae60),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Controles de cantidad
              Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (item.quantity > 1) {
                            setState(() {
                              item.quantity--;
                            });
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7f8c8d).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 16,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                      ),
                      
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            item.quantity++;
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3498db).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Color(0xFF3498db),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartFooter(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child:  SafeArea(
        child: Column(
          children: [
            // Resumen de costos
            ModernCard(
              padding:  const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      Text(
                        total.toStringAsFixed(0),
                        style:  const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       const Text(
                        'IVA (19%):',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      Text(
                        (total * 0.19).toStringAsFixed(0),
                        style:  const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      Text(
                        (total * 1.19).toStringAsFixed(0),
                        style:  const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF27ae60),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Botón de checkout
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Proceder al Pago',
                icon: Icons.payment,
                style: ModernButtonStyle.success,
                onPressed: () => context.push('/checkout'),
                // onPresse
              )
            ),
          ]
        )
      ),
    );
  }
}


class CartItem {
  final String id;
  final String name;
  final String description;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });
}

List<CartItem> _getSimulatedCartItems() {
  return [
    CartItem(
      id: '1',
      name: 'Cable de Red',
      description: 'Cable de Red de 100m de largo',
      price: 10000,
      quantity: 1,
    ),
    CartItem(
      id: '2',
      name: 'Cable de Blue',
      description: 'Cable de Blue de 100m de largo',
      price: 10000,
      quantity: 2,
    ),
    CartItem(
      id: '3',
      name: 'Cable de Green',
      description: 'Cable de Green de 100m de largo',
      price: 10000,
      quantity: 2,
    ),
    CartItem(
      id: '4',
      name: 'Cable de Yellow',
      description: 'Cable de Yellow de 100m de largo',
      price: 10000,
      quantity: 4,
    ),
    CartItem(
      id: '5',
      name: 'Cable de Purple',
      description: 'Cable de Purple de 100m de largo',
      price: 10000,
      quantity: 3,
    ),
  ];
}

double _calculateTotal(List<CartItem> cartItems) {
  return cartItems.fold<double>(
    0,
    (total, item) => total + item.price * item.quantity,
  );
}