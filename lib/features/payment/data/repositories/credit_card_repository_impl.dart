import '../../domain/entities/credit_card.dart';
import '../../domain/repositories/credit_card_repository.dart';
import '../datasources/credit_card_local_datasource.dart';

class CreditCardRepositoryImpl extends CreditCardRepository {
  final CreditCardLocalDatasource localDatasource;

  CreditCardRepositoryImpl({
    required this.localDatasource,
  });

  @override
  Future<List<CreditCard>> getAllCards() {
    return localDatasource.getAllCards();
  }

  @override
  Future<CreditCard?> getCardById(String id) {
    return localDatasource.getCardById(id);
  }

  @override
  Future<CreditCard?> getDefaultCard() {
    return localDatasource.getDefaultCard();
  }

  @override
  Future<void> saveCard(CreditCard card) {
    return localDatasource.saveCard(card);
  }

  @override
  Future<void> updateCard(CreditCard card) {
    return localDatasource.updateCard(card);
  }

  @override
  Future<void> deleteCard(String id) {
    return localDatasource.deleteCard(id);
  }

  @override
  Future<void> setDefaultCard(String id) {
    return localDatasource.setDefaultCard(id);
  }

  @override
  Future<void> deleteAllCards() {
    return localDatasource.deleteAllCards();
  }
}
