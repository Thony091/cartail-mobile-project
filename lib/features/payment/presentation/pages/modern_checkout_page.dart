import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import 'modern_checkout_widgets.dart';

class ModernCheckoutPage extends ConsumerStatefulWidget {
  static const name = 'ModernCheckoutPage';

  const ModernCheckoutPage({super.key});

  @override
  ModernCheckoutPageState createState() => ModernCheckoutPageState();
}

class ModernCheckoutPageState extends ConsumerState<ModernCheckoutPage> {
  String _selectedPaymentMethod = '';
  bool _savePaymentMethod = false;
  bool _isProcessing = false;

  // Datos simulados de servicios (en produccion vendrian del carrito/provider)
  final int _serviceCount = 3;
  final int _totalMinPrice = 140000;
  final int _totalMaxPrice = 220000;

  // Controladores para tarjetas
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  // Controladores para transferencia
  final _rutController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _rutController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estimatedTotal = ((_totalMinPrice + _totalMaxPrice) / 2).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar Servicios'),
        backgroundColor: const Color(0xFF3498db),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withValues(alpha: 0.1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen de servicios
                    FadeInDown(
                      child: ServiceSummaryCard(
                        serviceCount: _serviceCount,
                        totalMinPrice: _totalMinPrice,
                        totalMaxPrice: _totalMaxPrice,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Metodos de pago
                    FadeInLeft(
                      child: PaymentMethodsList(
                        selectedPaymentMethod: _selectedPaymentMethod,
                        onMethodSelected: (method) {
                          setState(() {
                            _selectedPaymentMethod = method;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Formulario segun metodo seleccionado
                    if (_selectedPaymentMethod.isNotEmpty)
                      FadeInUp(child: _buildPaymentForm()),
                  ],
                ),
              ),
            ),

            // Boton de pagar
            if (_selectedPaymentMethod.isNotEmpty)
              Container(
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
                      SizedBox(
                        width: double.infinity,
                        child: ModernButton(
                          height: 50,
                          text: 'Agregar metodo de pago',
                          icon: Icons.add,
                          style: ModernButtonStyle.warning,
                          isLoading: _isProcessing,
                          onPressed: () => context.push('/payment-methods'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ModernButton(
                          height: 50,
                          text: 'Pagar \$${_formatPrice(estimatedTotal)}',
                          icon: Icons.lock,
                          style: ModernButtonStyle.success,
                          isLoading: _isProcessing,
                          onPressed: _processPayment,
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _buildPaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'webpay':
      case 'tarjeta_internacional':
        return CardForm(
          paymentMethod: _selectedPaymentMethod,
          cardNumberController: _cardNumberController,
          cardHolderController: _cardHolderController,
          expiryDateController: _expiryDateController,
          cvvController: _cvvController,
          savePaymentMethod: _savePaymentMethod,
          onSaveChanged: (value) {
            setState(() {
              _savePaymentMethod = value ?? false;
            });
          },
        );
      case 'transferencia':
        return TransferForm(
          rutController: _rutController,
          emailController: _emailController,
        );
      case 'mercadopago':
        return const MercadoPagoForm();
      default:
        return const SizedBox();
    }
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simular procesamiento
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
    });

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentSuccessDialog(
        onViewOrders: () {
          Navigator.of(context).pop();
          context.go('/reservations');
        },
      ),
    );
  }
}
