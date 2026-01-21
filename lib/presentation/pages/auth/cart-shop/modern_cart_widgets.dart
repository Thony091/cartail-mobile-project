import 'package:flutter/material.dart';

import '../../../presentation_container.dart';

/// Representa un servicio en el carrito
class CartServiceItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final int minPrice;
  final int maxPrice;
  final List<String> images;

  CartServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    this.images = const [],
  });

  /// Precio promedio para calculos
  int get averagePrice => ((minPrice + maxPrice) / 2).round();
}

/// Helper para obtener icono segun categoria
IconData _getServiceIcon(String category) {
  switch (category.toLowerCase()) {
    case 'detailing':
      return Icons.cleaning_services;
    case 'mecánica':
      return Icons.build;
    case 'pintura':
      return Icons.brush;
    case 'neumáticos':
      return Icons.circle_outlined;
    default:
      return Icons.car_repair;
  }
}

/// Helper para obtener color segun categoria
Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'detailing':
      return const Color(0xFF3498db);
    case 'mecánica':
      return const Color(0xFFe67e22);
    case 'pintura':
      return const Color(0xFF9b59b6);
    case 'neumáticos':
      return const Color(0xFF34495e);
    default:
      return const Color(0xFF27ae60);
  }
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
              color: const Color(0xFF3498db).withValues(alpha: 0.1),
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
            'Tu carrito esta vacio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Agrega servicios para continuar',
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

class CartServiceCard extends StatelessWidget {
  final CartServiceItem item;
  final VoidCallback onDismiss;

  const CartServiceCard({
    super.key,
    required this.item,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(item.category);

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
              child: Icon(Icons.delete, color: Colors.white, size: 28),
            ),
          ),
        ),
        onDismissed: (direction) => onDismiss(),
        child: ModernCard(
          child: Row(
            children: [
              // Icono del servicio con color de categoria
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    _getServiceIcon(item.category),
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Informacion del servicio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoria chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

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
                        fontSize: 13,
                        color: Color(0xFF7f8c8d),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Rango de precios
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: Color(0xFF27ae60),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${_formatPrice(item.minPrice)} - \$${_formatPrice(item.maxPrice)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF27ae60),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Boton de eliminar
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

class CartFooter extends StatelessWidget {
  final int totalMin;
  final int totalMax;
  final int serviceCount;
  final VoidCallback onCheckout;

  const CartFooter({
    super.key,
    required this.totalMin,
    required this.totalMax,
    required this.serviceCount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final avgTotal = ((totalMin + totalMax) / 2).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Resumen de servicios
            ModernCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Servicios:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      Text(
                        '$serviceCount ${serviceCount == 1 ? 'servicio' : 'servicios'}',
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
                        'Rango de precio:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      Text(
                        '\$${_formatPrice(totalMin)} - \$${_formatPrice(totalMax)}',
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
                        'Total estimado:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      Text(
                        '\$${_formatPrice(avgTotal)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF27ae60),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'El precio final se definira al momento de la reserva',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF95a5a6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Boton de checkout
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
