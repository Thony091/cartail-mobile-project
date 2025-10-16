import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/shared/shared.dart';

class ModernCheckoutPage extends ConsumerStatefulWidget {
  static const name = 'ModernCheckoutPage';
  // final double totalAmount;
  
  const ModernCheckoutPage({
    super.key,
    // required this.totalAmount,
  });

  @override
  ModernCheckoutPageState createState() => ModernCheckoutPageState();
}

class ModernCheckoutPageState extends ConsumerState<ModernCheckoutPage> {
  String _selectedPaymentMethod = '';
  bool _savePaymentMethod = false;
  bool _isProcessing = false;
  
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
    final double totalAmount = 144000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Pago'),
        backgroundColor: const Color(0xFF3498db),
      ),
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen de compra
                    FadeInDown(
                      child: _buildOrderSummary( totalAmount ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Métodos de pago
                    FadeInLeft(
                      child: _buildPaymentMethods(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Formulario según método seleccionado
                    if (_selectedPaymentMethod.isNotEmpty)
                      FadeInUp(
                        child: _buildPaymentForm(),
                      ),
                  ],
                ),
              ),
            ),
            
            // Botón de pagar
            if (_selectedPaymentMethod.isNotEmpty)
              _buildPayButton( totalAmount ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary( double totalAmount ) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27ae60), Color(0xFF2ecc71)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen de Compra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    Text(
                      '5 productos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7f8c8d),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          _buildSummaryRow('Subtotal:', '\$${totalAmount.toStringAsFixed(0)}'),
          // _buildSummaryRow('Subtotal:', '\$${widget.totalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Envío:', '\$0'),
          const SizedBox(height: 8),
          // _buildSummaryRow('IVA (19%):', '\$${(totalAmount * 0.19).toStringAsFixed(0)}'),
          // _buildSummaryRow('IVA (19%):', '\$${(widget.totalAmount * 0.19).toStringAsFixed(0)}'),
          
          const Divider(height: 24),
          
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
                '\$${(totalAmount).toStringAsFixed(0)}',
                // '\$${(widget.totalAmount * 1.19).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF27ae60),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7f8c8d),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2c3e50),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona Método de Pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 20),
          
          // Webpay (Chile)
          _buildPaymentMethodTile(
            'webpay',
            'Webpay',
            'Tarjetas de crédito y débito',
            Icons.credit_card,
            const Color(0xFFe74c3c),
          ),
          
          const SizedBox(height: 12),
          
          // Transferencia Bancaria (Chile)
          _buildPaymentMethodTile(
            'transferencia',
            'Transferencia Bancaria',
            'Banco de Chile, BancoEstado, Santander, etc.',
            Icons.account_balance,
            const Color(0xFF3498db),
          ),
          
          const SizedBox(height: 12),
          
          // Mercado Pago (Internacional)
          _buildPaymentMethodTile(
            'mercadopago',
            'Mercado Pago',
            'Acepta múltiples métodos',
            Icons.payment,
            const Color(0xFFf39c12),
          ),
          
          const SizedBox(height: 12),
          
          // Tarjeta Internacional
          _buildPaymentMethodTile(
            'tarjeta_internacional',
            'Tarjeta Internacional',
            'Visa, Mastercard, American Express',
            Icons.credit_card,
            const Color(0xFF9b59b6),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : const Color(0xFFe2e8f0),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
                      color: isSelected ? color : const Color(0xFF2c3e50),
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
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'webpay':
      case 'tarjeta_internacional':
        return _buildCardForm();
      case 'transferencia':
        return _buildTransferForm();
      case 'mercadopago':
        return _buildMercadoPagoForm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCardForm() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.credit_card,
                color: _selectedPaymentMethod == 'webpay'
                    ? const Color(0xFFe74c3c)
                    : const Color(0xFF9b59b6),
              ),
              const SizedBox(width: 12),
              Text(
                _selectedPaymentMethod == 'webpay' ? 'Datos de Tarjeta' : 'Tarjeta Internacional',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Número de tarjeta
          ModernInputField(
            label: 'Número de Tarjeta',
            hint: '1234 5678 9012 3456',
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.credit_card),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberInputFormatter(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Titular
          ModernInputField(
            label: 'Titular de la Tarjeta',
            hint: 'Nombre como aparece en la tarjeta',
            controller: _cardHolderController,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          
          const SizedBox(height: 16),
          
          // Fecha de expiración y CVV
          Row(
            children: [
              Expanded(
                child: ModernInputField(
                  label: 'Vencimiento',
                  hint: 'MM/AA',
                  controller: _expiryDateController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.calendar_today),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryDateInputFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernInputField(
                  label: 'CVV',
                  hint: '123',
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Guardar método de pago
          CheckboxListTile(
            value: _savePaymentMethod,
            onChanged: (value) {
              setState(() {
                _savePaymentMethod = value ?? false;
              });
            },
            title: const Text(
              'Guardar este método de pago',
              style: TextStyle(fontSize: 14),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: const Color(0xFF3498db),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildTransferForm() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance, color: Color(0xFF3498db)),
              SizedBox(width: 12),
              Text(
                'Datos para Transferencia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // RUT
          ModernInputField(
            label: 'RUT',
            hint: '12345678-9',
            controller: _rutController,
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
          
          const SizedBox(height: 16),
          
          // Email
          ModernInputField(
            label: 'Email',
            hint: 'ejemplo@correo.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          
          const SizedBox(height: 20),
          
          // Instrucciones
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF3498db), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Instrucciones',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3498db),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '1. Realiza la transferencia a la siguiente cuenta:',
                  style: TextStyle(fontSize: 13, color: Color(0xFF2c3e50)),
                ),
                const SizedBox(height: 8),
                _buildBankInfo('Banco:', 'Banco de Chile'),
                _buildBankInfo('Tipo de cuenta:', 'Cuenta Corriente'),
                _buildBankInfo('Número:', '1234567890'),
                _buildBankInfo('RUT:', '12.345.678-9'),
                _buildBankInfo('Nombre:', 'DriveTail SpA'),
                const SizedBox(height: 12),
                const Text(
                  '2. Envía el comprobante al correo: pagos@drivetail.cl',
                  style: TextStyle(fontSize: 13, color: Color(0xFF2c3e50)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7f8c8d),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMercadoPagoForm() {
    return ModernCard(
      child: Column(
        children: [
          Icon(
            Icons.payment,
            size: 80,
            color: const Color(0xFFf39c12).withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'Serás redirigido a Mercado Pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Completa tu pago de forma segura en la plataforma de Mercado Pago',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton( double totalAmount ) {
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
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                height: 50,
                text: 'Agregar método de pago',
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
                text: 'Pagar \$${(totalAmount * 1.19).toStringAsFixed(0)}',
                // text: 'Pagar \$${(widget.totalAmount * 1.19).toStringAsFixed(0)}',
                icon: Icons.lock,
                style: ModernButtonStyle.success,
                isLoading: _isProcessing,
                onPressed: _processPayment,
              ),
            ),
          ],
        ),
      ),
    );
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF27ae60).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: Color(0xFF27ae60),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Pago Exitoso!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu pago ha sido procesado correctamente. Recibirás un correo de confirmación.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7f8c8d),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Ver Mis Pedidos',
                style: ModernButtonStyle.primary,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Input formatters
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length > 2) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
    
    return newValue;
  }
}
