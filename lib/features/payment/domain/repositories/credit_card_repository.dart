import '../entities/credit_card.dart';

abstract class CreditCardRepository {
  /// Obtiene todas las tarjetas guardadas
  Future<List<CreditCard>> getAllCards();

  /// Obtiene una tarjeta por ID
  Future<CreditCard?> getCardById(String id);

  /// Obtiene la tarjeta predeterminada
  Future<CreditCard?> getDefaultCard();

  /// Guarda una nueva tarjeta
  Future<void> saveCard(CreditCard card);

  /// Actualiza una tarjeta existente
  Future<void> updateCard(CreditCard card);

  /// Elimina una tarjeta por ID
  Future<void> deleteCard(String id);

  /// Establece una tarjeta como predeterminada
  Future<void> setDefaultCard(String id);

  /// Elimina todas las tarjetas
  Future<void> deleteAllCards();
}
