import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/pages/auth/cart-shop/modern_cart_widgets.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_scaffold_with_drawer.dart';

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
          ? EmptyCartView(
              onExplore: () {
                // Navegar a servicios
              },
            )
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
                        child: CartItemCard(
                          item: item,
                          onIncrement: () {
                            setState(() {
                              item.quantity++;
                            });
                          },
                          onDecrement: () {
                            if (item.quantity > 1) {
                              setState(() {
                                item.quantity--;
                              });
                            }
                          },
                          onDismiss: () {
                            setState(() {
                              // Remover item del carrito
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Footer con total y checkout
                CartFooter(
                  total: total,
                  onCheckout: () => context.push('/checkout'),
                ),
              ],
            ),
    );
  }
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
