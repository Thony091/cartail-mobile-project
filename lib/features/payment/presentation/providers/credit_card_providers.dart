import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/services/storage/encryption_service.dart';
import '../../../../config/services/storage/isar_service.dart';
import '../../data/datasources/credit_card_local_datasource.dart';
import '../../data/datasources/credit_card_local_datasource_impl.dart';
import '../../data/repositories/credit_card_repository_impl.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/repositories/credit_card_repository.dart';

// ========== SERVICE PROVIDERS ==========

/// Provider del servicio de encriptación
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

/// Provider del servicio de Isar
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

// ========== DATASOURCE PROVIDERS ==========

/// Provider del datasource local de tarjetas
final creditCardLocalDatasourceProvider = Provider<CreditCardLocalDatasource>((ref) {
  return CreditCardLocalDatasourceImpl(
    isarService: ref.watch(isarServiceProvider),
    encryptionService: ref.watch(encryptionServiceProvider),
  );
});

// ========== REPOSITORY PROVIDERS ==========

/// Provider del repositorio de tarjetas
final creditCardRepositoryProvider = Provider<CreditCardRepository>((ref) {
  return CreditCardRepositoryImpl(
    localDatasource: ref.watch(creditCardLocalDatasourceProvider),
  );
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
