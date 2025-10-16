import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/modern_button.dart';
import '../../shared/widgets/modern_card.dart';
import '../auth/modern_scaffold_with_drawer.dart';

class ModernPaymentMethodsPage extends ConsumerStatefulWidget {
  static const name = 'ModernPaymentMethodsPage';
  
  const ModernPaymentMethodsPage({super.key});

  @override
  ModernPaymentMethodsPageState createState() => ModernPaymentMethodsPageState();
}

class ModernPaymentMethodsPageState extends ConsumerState<ModernPaymentMethodsPage> {
  @override
  Widget build(BuildContext context) {
    // final paymentMethodsState = ref.watch(paymentMethodsProvider);
    final List<PaymentMethodData> paymentMethods = _getSimulatedPaymentMethods();

    return ModernScaffoldWithDrawer(
      title: 'Métodos de Pago',
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
        child: paymentMethods.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method = paymentMethods[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: index * 100),
                          child: _buildPaymentMethodCard(method, index),
                        );
                      },
                    ),
                  ),
                  
                  // Botón para agregar nuevo método
                  _buildAddButton(),
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
              color: const Color(0xFF3498db).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.credit_card_off,
              size: 60,
              color: Color(0xFF3498db),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay métodos de pago',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega un método de pago para compras más rápidas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7f8c8d),
            ),
          ),
          const SizedBox(height: 32),
          ModernButton(
            text: 'Agregar Método de Pago',
            icon: Icons.add,
            onPressed: _showAddPaymentMethodDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodData method, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(method.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) => _showDeleteConfirmation(method),
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
        child: ModernCard(
          child: Column(
            children: [
              Row(
                children: [
                  // Icono del método de pago
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getMethodColors(method.type),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _getMethodIcon(method.type),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  
                  const SizedBox(width: 15),
                  
                  // Información del método
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              method.type == 'card' 
                              ? _getCardBrand(method.last4) 
                              : method.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2c3e50),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (method.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF27ae60).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Principal',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF27ae60),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.type == 'card'
                              ? '**** **** **** ${method.last4}'
                              : method.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                        if (method.type == 'card' && method.expiryDate != null)
                          Text(
                            'Vence: ${method.expiryDate}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7f8c8d),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Botón de más opciones
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      if (!method.isDefault)
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.star, size: 20),
                              SizedBox(width: 12),
                              Text('Establecer como principal'),
                            ],
                          ),
                          onTap: () => _setAsDefault(method),
                        ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Editar'),
                          ],
                        ),
                        onTap: () => _editPaymentMethod(method),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Color(0xFFe74c3c)),
                            SizedBox(width: 12),
                            Text('Eliminar', style: TextStyle(color: Color(0xFFe74c3c))),
                          ],
                        ),
                        onTap: () => _deletePaymentMethod(method),
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

  Widget _buildAddButton() {
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
        child: SizedBox(
          width: double.infinity,
          child: ModernButton(
            text: 'Agregar Método de Pago',
            icon: Icons.add,
            style: ModernButtonStyle.primary,
            onPressed: _showAddPaymentMethodDialog,
          ),
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agregar Método de Pago',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona el tipo de método que deseas agregar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7f8c8d),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Opciones de métodos
                  _buildAddMethodOption(
                    'Tarjeta de Crédito/Débito',
                    'Visa, Mastercard, American Express',
                    Icons.credit_card,
                    const Color(0xFF3498db),
                    () {
                      Navigator.pop(context);
                      // Navegar a formulario de tarjeta
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildAddMethodOption(
                    'Cuenta Bancaria',
                    'Para transferencias automáticas',
                    Icons.account_balance,
                    const Color(0xFF27ae60),
                    () {
                      Navigator.pop(context);
                      // Navegar a formulario de cuenta bancaria
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildAddMethodOption(
                    'Webpay',
                    'Pago con Webpay Chile',
                    Icons.payment,
                    const Color(0xFFe74c3c),
                    () {
                      Navigator.pop(context);
                      // Navegar a configuración de Webpay
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMethodOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7f8c8d),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(PaymentMethodData method) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar Método de Pago'),
        content: Text(
          '¿Estás seguro de eliminar ${method.title}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ModernButton(
            text: 'Eliminar',
            style: ModernButtonStyle.danger,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(PaymentMethodData method) {
    setState(() {
      // Actualizar método predeterminado
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${method.title} establecido como principal'),
        backgroundColor: const Color(0xFF27ae60),
      ),
    );
  }

  void _editPaymentMethod(PaymentMethodData method) {
    // Navegar a edición
  }

  void _deletePaymentMethod(PaymentMethodData method) async {
    final confirmed = await _showDeleteConfirmation(method);
    if (confirmed == true && mounted) {
      setState(() {
        // Eliminar método
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${method.title} eliminado'),
            backgroundColor: const Color(0xFFe74c3c),
          ),
        );
      }
    }
  }

  List<Color> _getMethodColors(String type) {
    switch (type) {
      case 'card':
        return [const Color(0xFF3498db), const Color(0xFF2980b9)];
      case 'bank':
        return [const Color(0xFF27ae60), const Color(0xFF2ecc71)];
      case 'webpay':
        return [const Color(0xFFe74c3c), const Color(0xFFc0392b)];
      default:
        return [const Color(0xFF7f8c8d), const Color(0xFF95a5a6)];
    }
  }

  IconData _getMethodIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'bank':
        return Icons.account_balance;
      case 'webpay':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  String _getCardBrand(String last4) {
    // Lógica simple para detectar marca (podría ser más compleja)
    final firstDigit = int.tryParse(last4[0]) ?? 0;
    if (firstDigit == 4) return 'Visa';
    if (firstDigit == 5) return 'Mastercard';
    if (firstDigit == 3) return 'American Express';
    return 'Tarjeta';
  }

  List<PaymentMethodData> _getSimulatedPaymentMethods() {
    return [
      PaymentMethodData(
        id: '1',
        type: 'card',
        title: 'Tarjeta de Crédito',
        subtitle: 'Visa',
        last4: '4532',
        expiryDate: '12/25',
        isDefault: true,
      ),
      PaymentMethodData(
        id: '2',
        type: 'card',
        title: 'Tarjeta de Débito',
        subtitle: 'Mastercard',
        last4: '5123',
        expiryDate: '08/26',
        isDefault: false,
      ),
      PaymentMethodData(
        id: '3',
        type: 'bank',
        title: 'Cuenta Banco de Chile',
        subtitle: 'Cuenta Corriente ****5678',
        last4: '5678',
        expiryDate: null,
        isDefault: false,
      ),
    ];
  }
}

class PaymentMethodData {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String last4;
  final String? expiryDate;
  final bool isDefault;

  PaymentMethodData({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.last4,
    this.expiryDate,
    required this.isDefault,
  });
}