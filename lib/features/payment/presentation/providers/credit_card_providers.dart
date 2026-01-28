import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/credit_card.dart';
import '../../domain/repositories/credit_card_repository.dart';

// ========== REPOSITORY PROVIDERS ==========

/// Provider del repositorio de tarjetas (remote-only)
final creditCardRepositoryProvider = Provider<CreditCardRepository>((ref) {
  // Nota: CreditCard management is now remote-only
  // Local storage is disabled per migration away from Isar
  throw UnimplementedError('Credit card repository requires remote implementation');
});

// ========== STATE PROVIDERS ==========

/// Provider que obtiene todas las tarjetas
final creditCardsProvider = FutureProvider<List<CreditCard>>((ref) async {
  final repository = ref.watch(creditCardRepositoryProvider);
  return await repository.getAllCards();
});

/// Provider que obtiene la tarjeta predeterminada
final defaultCreditCardProvider = FutureProvider<CreditCard?>((ref) async {
  final repository = ref.watch(creditCardRepositoryProvider);
  return await repository.getDefaultCard();
});

/// Provider para gestionar las acciones de tarjetas
final creditCardActionsProvider = Provider<CreditCardActions>((ref) {
  return CreditCardActions(ref);
});

// ========== ACTIONS CLASS ==========

/// Clase que contiene las acciones para gestionar tarjetas
class CreditCardActions {
  final Ref ref;

  CreditCardActions(this.ref);

  /// Guarda una nueva tarjeta
  Future<void> saveCard({
    required String cardholderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    bool setAsDefault = false,
  }) async {
    final repository = ref.read(creditCardRepositoryProvider);

    // Detectar tipo de tarjeta
    final cardType = CreditCard.detectCardType(cardNumber);

    // Generar ID único
    const uuid = Uuid();
    final id = uuid.v4();

    final card = CreditCard(
      id: id,
      cardholderName: cardholderName,
      cardNumber: cardNumber,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cvv: cvv,
      cardType: cardType,
      isDefault: setAsDefault,
      createdAt: DateTime.now(),
    );

    await repository.saveCard(card);

    // Refrescar la lista de tarjetas
    ref.invalidate(creditCardsProvider);
    ref.invalidate(defaultCreditCardProvider);
  }

  /// Actualiza una tarjeta existente
  Future<void> updateCard(CreditCard card) async {
    final repository = ref.read(creditCardRepositoryProvider);
    await repository.updateCard(card);

    // Refrescar la lista
    ref.invalidate(creditCardsProvider);
    ref.invalidate(defaultCreditCardProvider);
  }

  /// Elimina una tarjeta
  Future<void> deleteCard(String id) async {
    final repository = ref.read(creditCardRepositoryProvider);
    await repository.deleteCard(id);

    // Refrescar la lista
    ref.invalidate(creditCardsProvider);
    ref.invalidate(defaultCreditCardProvider);
  }

  /// Establece una tarjeta como predeterminada
  Future<void> setDefaultCard(String id) async {
    final repository = ref.read(creditCardRepositoryProvider);
    await repository.setDefaultCard(id);

    // Refrescar la lista
    ref.invalidate(creditCardsProvider);
    ref.invalidate(defaultCreditCardProvider);
  }

  /// Elimina todas las tarjetas
  Future<void> deleteAllCards() async {
    final repository = ref.read(creditCardRepositoryProvider);
    await repository.deleteAllCards();

    // Refrescar la lista
    ref.invalidate(creditCardsProvider);
    ref.invalidate(defaultCreditCardProvider);
  }
}
