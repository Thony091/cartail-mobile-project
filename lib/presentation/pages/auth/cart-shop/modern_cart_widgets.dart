import 'package:flutter/material.dart';

import '../../../presentation_container.dart';

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

class EmptyCartView extends StatelessWidget {
  final VoidCallback onExplore;

  const EmptyCartView({super.key, required this.onExplore});

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
            style: TextStyle(fontSize: 16, color: Color(0xFF7f8c8d)),
          ),

          const SizedBox(height: 32),

          ModernButton(
            text: 'Explorar Servicios',
            icon: Icons.explore,
            onPressed: onExplore,
          ),
        ],
      ),
    );
  }
}

class CartItemCard extends StatefulWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDismiss;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDismiss,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(widget.item.id),
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
              child: Icon(Icons.delete, color: Colors.white, size: 28),
            ),
          ),
        ),
        onDismissed: (direction) => widget.onDismiss(),
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
                      widget.item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.item.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7f8c8d),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.item.price.toStringAsFixed(0),
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
                        onTap: widget.onDecrement,
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
                          '${widget.item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: widget.onIncrement,
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
}

class CartFooter extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;

  const CartFooter({super.key, required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
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
      child: SafeArea(
        child: Column(
          children: [
            // Resumen de costos
            ModernCard(
              padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(
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
                        style: const TextStyle(
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
                        style: const TextStyle(
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
                onPressed: onCheckout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
