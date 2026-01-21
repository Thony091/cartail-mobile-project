import 'package:isar_community/isar.dart';
import '../../../../config/services/storage/encryption_service.dart';
import '../../../../config/services/storage/isar_service.dart';
import '../../domain/entities/credit_card.dart';
import '../models/credit_card_model.dart';
import 'credit_card_local_datasource.dart';

/// Implementación del datasource local usando Isar
class CreditCardLocalDatasourceImpl extends CreditCardLocalDatasource {
  final IsarService isarService;
  final EncryptionService encryptionService;

  CreditCardLocalDatasourceImpl({
    required this.isarService,
    required this.encryptionService,
  });

  Isar get _isar => isarService.isar;

  @override
  Future<List<CreditCard>> getAllCards() async {
    final cards = await _isar.creditCardModels.where().findAll();
    return cards.map((model) => model.toEntity(encryptionService)).toList();
  }

  @override
  Future<CreditCard?> getCardById(String id) async {
    final card = await _isar.creditCardModels
        .filter()
        .localIdEqualTo(id)
        .findFirst();

    return card?.toEntity(encryptionService);
  }

  @override
  Future<CreditCard?> getDefaultCard() async {
    final card = await _isar.creditCardModels
        .filter()
        .isDefaultEqualTo(true)
        .findFirst();

    return card?.toEntity(encryptionService);
  }

  @override
  Future<void> saveCard(CreditCard card) async {
    final model = CreditCardModel.fromEntity(card, encryptionService);

    await _isar.writeTxn(() async {
      // Si esta tarjeta debe ser la predeterminada, desmarcar las demás
      if (card.isDefault) {
        await _setAllCardsNonDefault();
      }

      await _isar.creditCardModels.put(model);
    });
  }

  @override
  Future<void> updateCard(CreditCard card) async {
    final existingModel = await _isar.creditCardModels
        .filter()
        .localIdEqualTo(card.id)
        .findFirst();

    if (existingModel == null) {
      throw Exception('Tarjeta no encontrada');
    }

    await _isar.writeTxn(() async {
      // Si esta tarjeta debe ser la predeterminada, desmarcar las demás
      if (card.isDefault && !existingModel.isDefault) {
        await _setAllCardsNonDefault();
      }

      final updatedModel = CreditCardModel.fromEntity(card, encryptionService);
      updatedModel.id = existingModel.id; // Mantener el ID de Isar
      await _isar.creditCardModels.put(updatedModel);
    });
  }

  @override
  Future<void> deleteCard(String id) async {
    await _isar.writeTxn(() async {
      final card = await _isar.creditCardModels
          .filter()
          .localIdEqualTo(id)
          .findFirst();

      if (card != null) {
        await _isar.creditCardModels.delete(card.id);

        // Si eliminamos la tarjeta predeterminada, establecer otra como predeterminada
        if (card.isDefault) {
          final firstCard = await _isar.creditCardModels.where().findFirst();
          if (firstCard != null) {
            firstCard.isDefault = true;
            await _isar.creditCardModels.put(firstCard);
          }
        }
      }
    });
  }

  @override
  Future<void> setDefaultCard(String id) async {
    await _isar.writeTxn(() async {
      // Desmarcar todas las tarjetas
      await _setAllCardsNonDefault();

      // Marcar la tarjeta seleccionada como predeterminada
      final card = await _isar.creditCardModels
          .filter()
          .localIdEqualTo(id)
          .findFirst();

      if (card != null) {
        card.isDefault = true;
        await _isar.creditCardModels.put(card);
      }
    });
  }

  @override
  Future<void> deleteAllCards() async {
    await _isar.writeTxn(() async {
      await _isar.creditCardModels.clear();
    });
  }

  /// Helper: Establece todas las tarjetas como no predeterminadas
  Future<void> _setAllCardsNonDefault() async {
    final allCards = await _isar.creditCardModels.where().findAll();
    for (final card in allCards) {
      card.isDefault = false;
      await _isar.creditCardModels.put(card);
    }
  }
}
