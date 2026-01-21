import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';

class ServiceSummaryCard extends StatelessWidget {
  final int serviceCount;
  final int totalMinPrice;
  final int totalMaxPrice;

  const ServiceSummaryCard({
    super.key,
    required this.serviceCount,
    required this.totalMinPrice,
    required this.totalMaxPrice,
  });

  @override
  Widget build(BuildContext context) {
    final estimatedTotal = ((totalMinPrice + totalMaxPrice) / 2).round();

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
                    colors: [Color(0xFF3498db), Color(0xFF2980b9)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.car_repair,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de Servicios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    Text(
                      '$serviceCount ${serviceCount == 1 ? 'servicio' : 'servicios'} seleccionados',
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

          const Divider(height: 32),

          _buildSummaryRow(
            'Rango de precio:',
            '\$${_formatPrice(totalMinPrice)} - \$${_formatPrice(totalMaxPrice)}',
          ),
          const SizedBox(height: 8),

          const Divider(height: 24),

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
                '\$${_formatPrice(estimatedTotal)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF27ae60),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF3498db),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'El precio final se confirmara segun las caracteristicas de tu vehiculo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3498db),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
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
}

class PaymentMethodsList extends StatelessWidget {
  final String selectedPaymentMethod;
  final ValueChanged<String> onMethodSelected;

  const PaymentMethodsList({
    super.key,
    required this.selectedPaymentMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
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

          _buildPaymentMethodTile(
            'webpay',
            'Webpay',
            'Tarjetas de crédito y débito',
            Icons.credit_card,
            const Color(0xFFe74c3c),
          ),

          const SizedBox(height: 12),

          _buildPaymentMethodTile(
            'transferencia',
            'Transferencia Bancaria',
            'Banco de Chile, BancoEstado, Santander, etc.',
            Icons.account_balance,
            const Color(0xFF3498db),
          ),

          const SizedBox(height: 12),

          _buildPaymentMethodTile(
            'mercadopago',
            'Mercado Pago',
            'Acepta múltiples métodos',
            Icons.payment,
            const Color(0xFFf39c12),
          ),

          const SizedBox(height: 12),

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
    final isSelected = selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () => onMethodSelected(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
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
                color: color.withValues(alpha: 0.1),
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
            if (isSelected) Icon(Icons.check_circle, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}

class CardForm extends StatelessWidget {
  final String paymentMethod;
  final TextEditingController cardNumberController;
  final TextEditingController cardHolderController;
  final TextEditingController expiryDateController;
  final TextEditingController cvvController;
  final bool savePaymentMethod;
  final ValueChanged<bool?> onSaveChanged;

  const CardForm({
    super.key,
    required this.paymentMethod,
    required this.cardNumberController,
    required this.cardHolderController,
    required this.expiryDateController,
    required this.cvvController,
    required this.savePaymentMethod,
    required this.onSaveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.credit_card,
                color: paymentMethod == 'webpay'
                    ? const Color(0xFFe74c3c)
                    : const Color(0xFF9b59b6),
              ),
              const SizedBox(width: 12),
              Text(
                paymentMethod == 'webpay'
                    ? 'Datos de Tarjeta'
                    : 'Tarjeta Internacional',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ModernInputField(
            label: 'Número de Tarjeta',
            hint: '1234 5678 9012 3456',
            controller: cardNumberController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.credit_card),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(),
            ],
          ),

          const SizedBox(height: 16),

          ModernInputField(
            label: 'Titular de la Tarjeta',
            hint: 'Nombre como aparece en la tarjeta',
            controller: cardHolderController,
            prefixIcon: const Icon(Icons.person_outline),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ModernInputField(
                  label: 'Vencimiento',
                  hint: 'MM/AA',
                  controller: expiryDateController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.calendar_today),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    ExpiryDateInputFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernInputField(
                  label: 'CVV',
                  hint: '123',
                  controller: cvvController,
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

          CheckboxListTile(
            value: savePaymentMethod,
            onChanged: onSaveChanged,
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
}

class TransferForm extends StatelessWidget {
  final TextEditingController rutController;
  final TextEditingController emailController;

  const TransferForm({
    super.key,
    required this.rutController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
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

          ModernInputField(
            label: 'RUT',
            hint: '12345678-9',
            controller: rutController,
            prefixIcon: const Icon(Icons.badge_outlined),
          ),

          const SizedBox(height: 16),

          ModernInputField(
            label: 'Email',
            hint: 'ejemplo@correo.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF3498db),
                      size: 20,
                    ),
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
}

class MercadoPagoForm extends StatelessWidget {
  const MercadoPagoForm({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        children: [
          Icon(
            Icons.payment,
            size: 80,
            color: const Color(0xFFf39c12).withValues(alpha: 0.5),
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
            style: TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
          ),
        ],
      ),
    );
  }
}

class PaymentSuccessDialog extends StatelessWidget {
  final VoidCallback onViewOrders;

  const PaymentSuccessDialog({super.key, required this.onViewOrders});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF27ae60).withValues(alpha: 0.1),
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
            'Tu pago ha sido procesado correctamente. Recibiras un correo con los detalles de tu reserva.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ModernButton(
              text: 'Ver Mis Reservas',
              style: ModernButtonStyle.primary,
              onPressed: onViewOrders,
            ),
          ),
        ],
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
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

class ExpiryDateInputFormatter extends TextInputFormatter {
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
