import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/theme/modern_app_theme.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';

class CreditCardPreview extends StatelessWidget {
  final String cardNumber;
  final String cardholderName;
  final String expiryDate;

  const CreditCardPreview({
    super.key,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
  });

  String _formatCardNumber(String number) {
    final cleaned = number.replaceAll(' ', '');
    if (cleaned.isEmpty) return '**** **** **** ****';

    final buffer = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(i < cleaned.length ? cleaned[i] : '*');
    }
    return buffer.toString();
  }

  String _getCardBrand(String number) {
    final cleaned = number.replaceAll(' ', '');
    if (cleaned.isEmpty) return 'TARJETA';
    if (cleaned.startsWith('4')) return 'VISA';
    if (cleaned.startsWith(RegExp(r'^5[1-5]'))) return 'MASTERCARD';
    if (cleaned.startsWith(RegExp(r'^3[47]'))) return 'AMEX';
    return 'TARJETA';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ModernAppTheme.purpleLight, ModernAppTheme.purpleDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernAppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.credit_card, color: Colors.white, size: 40),
                Text(
                  _getCardBrand(cardNumber),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              _formatCardNumber(cardNumber),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TITULAR',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cardholderName.isEmpty
                          ? 'NOMBRE APELLIDO'
                          : cardholderName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VENCE',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expiryDate.isEmpty ? 'MM/AA' : expiryDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CardNumberField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const CardNumberField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Número de Tarjeta',
        hintText: '1234 5678 9012 3456',
        prefixIcon: Icon(Icons.credit_card),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        CardNumberFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa el número de tarjeta';
        }
        final cleaned = value.replaceAll(' ', '');
        if (cleaned.length < 13 || cleaned.length > 19) {
          return 'Número de tarjeta inválido';
        }
        return null;
      },
      onChanged: (_) => onChanged(),
    );
  }
}

class CardholderField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const CardholderField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Titular de la Tarjeta',
        hintText: 'Nombre completo',
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa el nombre del titular';
        }
        return null;
      },
      onChanged: (_) => onChanged(),
    );
  }
}

class ExpiryField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const ExpiryField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Vencimiento',
        hintText: 'MM/AA',
        prefixIcon: Icon(Icons.calendar_today),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        ExpiryDateFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa la fecha';
        }
        if (!value.contains('/') || value.length != 5) {
          return 'Formato inválido';
        }
        return null;
      },
      onChanged: (_) => onChanged(),
    );
  }
}

class CvvField extends StatelessWidget {
  final TextEditingController controller;

  const CvvField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'CVV',
        hintText: '123',
        prefixIcon: Icon(Icons.lock),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa el CVV';
        }
        if (value.length < 3) {
          return 'CVV inválido';
        }
        return null;
      },
    );
  }
}

class DefaultCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const DefaultCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ModernAppTheme.borderLight),
      ),
      child: CheckboxListTile(
        title: const Text('Establecer como tarjeta predeterminada'),
        subtitle: const Text('Se usará automáticamente en pagos'),
        value: value,
        onChanged: (newValue) => onChanged(newValue ?? false),
        activeColor: ModernAppTheme.primaryBlue,
      ),
    );
  }
}

class SaveCardButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SaveCardButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ModernButton(
        text: isLoading ? 'Guardando...' : 'Guardar Tarjeta',
        icon: isLoading ? null : Icons.save,
        onPressed: isLoading ? null : onPressed,
        style: ModernButtonStyle.primary,
      ),
    );
  }
}

// ========== FORMATTERS ==========

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length > 2 && !text.contains('/')) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }

    return newValue;
  }
}
