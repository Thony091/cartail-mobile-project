import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../domain/entities/credit_card.dart';
import '../providers/credit_card_providers.dart';

class PaymentMethodsEmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const PaymentMethodsEmptyState({super.key, required this.onAddPressed});

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
            style: TextStyle(fontSize: 16, color: Color(0xFF7f8c8d)),
          ),
          const SizedBox(height: 32),
          ModernButton(
            text: 'Agregar Método de Pago',
            icon: Icons.add,
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }
}

class PaymentMethodsErrorState extends StatelessWidget {
  final Object error;

  const PaymentMethodsErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Color(0xFFe74c3c)),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar tarjetas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
          ),
        ],
      ),
    );
  }
}

class CreditCardItem extends ConsumerWidget {
  final String cardId;

  const CreditCardItem({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(creditCardsProvider);

    return cardsAsync.when(
      data: (cards) {
        final card = cards.firstWhere((c) => c.id == cardId);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: Key(card.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) =>
                _showDeleteConfirmation(context, card),
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
            child: ModernCard(
              child: Row(
                children: [
                  CardIcon(cardType: card.cardType),
                  const SizedBox(width: 15),
                  CardInfo(
                    cardType: card.cardType,
                    maskedNumber: card.maskedNumber,
                    expiryDate: card.formattedExpiry,
                    isDefault: card.isDefault,
                  ),
                  CardMenu(
                    cardId: card.id,
                    isDefault: card.isDefault,
                    cardTypeName: card.cardType.displayName,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, CreditCard card) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Tarjeta'),
        content: Text(
          '¿Estás seguro de eliminar la tarjeta ${card.cardType.displayName} ${card.maskedNumber}?',
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
}

class CardIcon extends StatelessWidget {
  final CardType cardType;

  const CardIcon({super.key, required this.cardType});

  List<Color> _getCardColors(CardType type) {
    switch (type) {
      case CardType.visa:
        return [const Color(0xFF1a1f71), const Color(0xFF0d47a1)];
      case CardType.mastercard:
        return [const Color(0xFFeb001b), const Color(0xFFff5f00)];
      case CardType.americanExpress:
        return [const Color(0xFF006fcf), const Color(0xFF0077c8)];
      case CardType.discover:
        return [const Color(0xFFff6000), const Color(0xFFf48120)];
      case CardType.unknown:
        return [const Color(0xFF7f8c8d), const Color(0xFF95a5a6)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _getCardColors(cardType)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.credit_card, color: Colors.white, size: 24),
    );
  }
}

class CardInfo extends StatelessWidget {
  final CardType cardType;
  final String maskedNumber;
  final String expiryDate;
  final bool isDefault;

  const CardInfo({
    super.key,
    required this.cardType,
    required this.maskedNumber,
    required this.expiryDate,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                cardType.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(width: 8),
              if (isDefault)
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
            maskedNumber,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
          ),
          Text(
            'Vence: $expiryDate',
            style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
          ),
        ],
      ),
    );
  }
}

class CardMenu extends ConsumerWidget {
  final String cardId;
  final bool isDefault;
  final String cardTypeName;

  const CardMenu({
    super.key,
    required this.cardId,
    required this.isDefault,
    required this.cardTypeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        if (!isDefault)
          PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.star, size: 20),
                SizedBox(width: 12),
                Text('Establecer como principal'),
              ],
            ),
            onTap: () => _setAsDefault(context, ref),
          ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.delete, size: 20, color: Color(0xFFe74c3c)),
              SizedBox(width: 12),
              Text('Eliminar', style: TextStyle(color: Color(0xFFe74c3c))),
            ],
          ),
          onTap: () => _deleteCard(context, ref),
        ),
      ],
    );
  }

  Future<void> _setAsDefault(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(creditCardActionsProvider);
    await actions.setDefaultCard(cardId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$cardTypeName establecida como principal'),
          backgroundColor: const Color(0xFF27ae60),
        ),
      );
    }
  }

  Future<void> _deleteCard(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(creditCardActionsProvider);
    await actions.deleteCard(cardId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarjeta eliminada'),
          backgroundColor: Color(0xFFe74c3c),
        ),
      );
    }
  }
}

class AddPaymentMethodButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddPaymentMethodButton({super.key, required this.onPressed});

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
        child: SizedBox(
          width: double.infinity,
          child: ModernButton(
            text: 'Agregar Método de Pago',
            icon: Icons.add,
            style: ModernButtonStyle.primary,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
