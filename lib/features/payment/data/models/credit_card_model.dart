import 'package:isar_community/isar.dart';
import '../../domain/entities/credit_card.dart';
import '../../../../config/services/storage/encryption_service.dart';

part 'credit_card_model.g.dart';

/// Modelo de tarjeta de crédito para almacenamiento local con Isar
/// NOTA: Este modelo almacena los datos sensibles (número de tarjeta y CVV) encriptados
@Collection()
class CreditCardModel {
  /// ID autogenerado por Isar
  Id id = Isar.autoIncrement;

  /// ID único de la tarjeta (UUID) - Indexado para búsquedas rápidas
  @Index(unique: true)
  late String localId;

  /// Nombre del titular
  late String cardholderName;

  /// Número de tarjeta ENCRIPTADO
  late String encryptedCardNumber;

  /// Mes de expiración (MM)
  late String expiryMonth;

  /// Año de expiración (YYYY)
  late String expiryYear;

  /// CVV ENCRIPTADO
  late String encryptedCvv;

  /// Tipo de tarjeta (visa, mastercard, etc.)
  late String cardTypeName;

  /// Si es la tarjeta predeterminada - Indexado
  @Index()
  late bool isDefault;

  /// Fecha de creación
  late DateTime createdAt;

  /// Fecha de última actualización
  DateTime? updatedAt;

  /// Constructor sin argumentos requerido por Isar
  CreditCardModel();

  /// Constructor desde entidad
  factory CreditCardModel.fromEntity(CreditCard card, EncryptionService encryption) {
    final model = CreditCardModel()
      ..localId = card.id
      ..cardholderName = card.cardholderName
      ..encryptedCardNumber = encryption.encrypt(card.cardNumber)
      ..expiryMonth = card.expiryMonth
      ..expiryYear = card.expiryYear
      ..encryptedCvv = encryption.encrypt(card.cvv)
      ..cardTypeName = card.cardType.name
      ..isDefault = card.isDefault
      ..createdAt = card.createdAt
      ..updatedAt = card.updatedAt;

    return model;
  }

  /// Convierte el modelo a entidad
  CreditCard toEntity(EncryptionService encryption) {
    return CreditCard(
      id: localId,
      cardholderName: cardholderName,
      cardNumber: encryption.decrypt(encryptedCardNumber),
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cvv: encryption.decrypt(encryptedCvv),
      cardType: _parseCardType(cardTypeName),
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  CardType _parseCardType(String typeName) {
    return CardType.values.firstWhere(
      (type) => type.name == typeName,
      orElse: () => CardType.unknown,
    );
  }
}
