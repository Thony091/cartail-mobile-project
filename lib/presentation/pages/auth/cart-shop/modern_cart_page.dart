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
  late List<CartServiceItem> _cartServices;

  @override
  void initState() {
    super.initState();
    _cartServices = _getSimulatedServices();
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals(_cartServices);

    return ModernScaffoldWithDrawer(
      title: 'Mi Carrito',
      body: _cartServices.isEmpty
          ? EmptyCartView(
              onExplore: () {
                context.push('/services');
              },
            )
          : Column(
              children: [
                // Header informativo
                _buildHeader(),

                // Lista de servicios
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _cartServices.length,
                    itemBuilder: (context, index) {
                      final service = _cartServices[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 100),
                        child: CartServiceCard(
                          item: service,
                          onDismiss: () {
                            setState(() {
                              _cartServices.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${service.name} eliminado del carrito',
                                ),
                                backgroundColor: const Color(0xFFe74c3c),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                action: SnackBarAction(
                                  label: 'Deshacer',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      _cartServices.insert(index, service);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Footer con totales y checkout
                CartFooter(
                  totalMin: totals['min']!,
                  totalMax: totals['max']!,
                  serviceCount: _cartServices.length,
                  onCheckout: () => context.push('/checkout'),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3498db).withValues(alpha: 0.1),
            const Color(0xFF27ae60).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3498db).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.car_repair,
              color: Color(0xFF3498db),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Servicios seleccionados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tienes ${_cartServices.length} ${_cartServices.length == 1 ? 'servicio' : 'servicios'} en tu carrito',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Datos simulados de servicios en el carrito
List<CartServiceItem> _getSimulatedServices() {
  return [
    CartServiceItem(
      id: '1',
      name: 'Detailing Premium',
      description: 'Limpieza profunda interior y exterior con proteccion ceramica',
      category: 'Detailing',
      minPrice: 80000,
      maxPrice: 120000,
    ),
    CartServiceItem(
      id: '2',
      name: 'Cambio de Aceite',
      description: 'Cambio de aceite y filtros con revision general',
      category: 'Mecánica',
      minPrice: 25000,
      maxPrice: 45000,
    ),
    CartServiceItem(
      id: '3',
      name: 'Alineacion y Balanceo',
      description: 'Alineacion computarizada y balanceo de las 4 ruedas',
      category: 'Neumáticos',
      minPrice: 35000,
      maxPrice: 55000,
    ),
  ];
}

/// Calcula los totales minimo y maximo
Map<String, int> _calculateTotals(List<CartServiceItem> services) {
  int totalMin = 0;
  int totalMax = 0;

  for (final service in services) {
    totalMin += service.minPrice;
    totalMax += service.maxPrice;
  }

  return {'min': totalMin, 'max': totalMax};
}
