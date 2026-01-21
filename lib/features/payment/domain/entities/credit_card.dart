enum CardType {
  visa,
  mastercard,
  americanExpress,
  discover,
  unknown;

  String get displayName {
    switch (this) {
      case CardType.visa:
        return 'Visa';
      case CardType.mastercard:
        return 'Mastercard';
      case CardType.americanExpress:
        return 'American Express';
      case CardType.discover:
        return 'Discover';
      case CardType.unknown:
        return 'Tarjeta';
    }
  }
}

class CreditCard {
  final String id;
  final String cardholderName;
  final String cardNumber; // Almacenado encriptado
  final String expiryMonth;
  final String expiryYear;
  final String cvv; // Almacenado encriptado
  final CardType cardType;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CreditCard({
    required this.id,
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.cardType,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Obtiene los últimos 4 dígitos de la tarjeta (sin encriptar)
  String get last4 {
    if (cardNumber.length >= 4) {
      return cardNumber.substring(cardNumber.length - 4);
    }
    return cardNumber;
  }

  /// Obtiene la tarjeta enmascarada (**** **** **** 1234)
  String get maskedNumber {
    final last4Digits = last4;
    return '**** **** **** $last4Digits';
  }

  /// Verifica si la tarjeta está expirada
  bool get isExpired {
    final now = DateTime.now();
    final expiryDate = DateTime(
      int.parse(expiryYear),
      int.parse(expiryMonth),
    );
    return now.isAfter(expiryDate);
  }

  /// Obtiene el mes/año de expiración formateado (MM/YY)
  String get formattedExpiry {
    return '$expiryMonth/${expiryYear.substring(2)}';
  }

  CreditCard copyWith({
    String? id,
    String? cardholderName,
    String? cardNumber,
    String? expiryMonth,
    String? expiryYear,
    String? cvv,
    CardType? cardType,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCard(
      id: id ?? this.id,
      cardholderName: cardholderName ?? this.cardholderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvv: cvv ?? this.cvv,
      cardType: cardType ?? this.cardType,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Detecta el tipo de tarjeta basado en el número
  static CardType detectCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return CardType.unknown;

    // Visa: empieza con 4
    if (cleaned.startsWith('4')) {
      return CardType.visa;
    }

    // Mastercard: empieza con 51-55 o 2221-2720
    if (cleaned.startsWith(RegExp(r'^5[1-5]')) ||
        cleaned.startsWith(RegExp(r'^2(22[1-9]|2[3-9][0-9]|[3-6][0-9]{2}|7[0-1][0-9]|720)'))) {
      return CardType.mastercard;
    }

    // American Express: empieza con 34 o 37
    if (cleaned.startsWith(RegExp(r'^3[47]'))) {
      return CardType.americanExpress;
    }

    // Discover: empieza con 6011, 622126-622925, 644-649, o 65
    if (cleaned.startsWith('6011') ||
        cleaned.startsWith(RegExp(r'^62212[6-9]')) ||
        cleaned.startsWith(RegExp(r'^6229[01][0-9]')) ||
        cleaned.startsWith(RegExp(r'^622[2-8][0-9]{2}')) ||
        cleaned.startsWith(RegExp(r'^6229[2][0-5]')) ||
        cleaned.startsWith(RegExp(r'^64[4-9]')) ||
        cleaned.startsWith('65')) {
      return CardType.discover;
    }

    return CardType.unknown;
  }
}
