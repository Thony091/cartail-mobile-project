import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../providers/credit_card_providers.dart';
import 'modern_payment_methods_widgets.dart';

class ModernPaymentMethodsPage extends ConsumerStatefulWidget {
  static const name = 'ModernPaymentMethodsPage';

  const ModernPaymentMethodsPage({super.key});

  @override
  ModernPaymentMethodsPageState createState() =>
      ModernPaymentMethodsPageState();
}

class ModernPaymentMethodsPageState
    extends ConsumerState<ModernPaymentMethodsPage> {
  @override
  Widget build(BuildContext context) {
    final cardsAsyncValue = ref.watch(creditCardsProvider);

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
        child: cardsAsyncValue.when(
          data: (cards) => cards.isEmpty
              ? PaymentMethodsEmptyState(
                  onAddPressed: () => context.push('/payment/add-card'),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: index * 100),
                            child: CreditCardItem(cardId: card.id),
                          );
                        },
                      ),
                    ),
                    AddPaymentMethodButton(
                      onPressed: () => context.push('/payment/add-card'),
                    ),
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => PaymentMethodsErrorState(error: error),
        ),
      ),
    );
  }
}
