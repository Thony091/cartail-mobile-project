import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/modern_app_theme.dart';
import '../providers/credit_card_providers.dart';
import 'modern_add_card_widgets.dart';

class AddCreditCardPage extends ConsumerStatefulWidget {
  static const name = 'AddCreditCardPage';

  const AddCreditCardPage({super.key});

  @override
  ConsumerState<AddCreditCardPage> createState() => _AddCreditCardPageState();
}

class _AddCreditCardPageState extends ConsumerState<AddCreditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardholderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _setAsDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final expiryParts = _expiryController.text.split('/');
      final month = expiryParts[0].trim();
      final year = '20${expiryParts[1].trim()}';

      final actions = ref.read(creditCardActionsProvider);
      await actions.saveCard(
        cardholderName: _cardholderController.text,
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryMonth: month,
        expiryYear: year,
        cvv: _cvvController.text,
        setAsDefault: _setAsDefault,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarjeta guardada exitosamente'),
            backgroundColor: ModernAppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar tarjeta: $e'),
            backgroundColor: ModernAppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernAppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Agregar Tarjeta'),
        elevation: 0,
        backgroundColor: ModernAppTheme.primaryBlue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FadeInDown(
              child: CreditCardPreview(
                cardNumber: _cardNumberController.text,
                cardholderName: _cardholderController.text,
                expiryDate: _expiryController.text,
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: CardNumberField(
                        controller: _cardNumberController,
                        onChanged: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: CardholderField(
                        controller: _cardholderController,
                        onChanged: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Row(
                        children: [
                          Expanded(
                            child: ExpiryField(
                              controller: _expiryController,
                              onChanged: () => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: CvvField(controller: _cvvController)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: DefaultCheckbox(
                        value: _setAsDefault,
                        onChanged: (value) =>
                            setState(() => _setAsDefault = value),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: SaveCardButton(
                        isLoading: _isLoading,
                        onPressed: _saveCard,
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
}
