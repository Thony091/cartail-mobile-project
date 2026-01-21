class PaymentMethodNotFound implements Exception {}

class PaymentStateNotFound implements Exception {}

class TransactionPaymentNotFound implements Exception {}

class PaymentCreateError implements Exception {
  final String message;
  PaymentCreateError(this.message);
}

class PaymentUpdateError implements Exception {
  final String message;
  PaymentUpdateError(this.message);
}

class PaymentDeleteError implements Exception {
  final String message;
  PaymentDeleteError(this.message);
}

class PaymentFetchError implements Exception {
  final String message;
  PaymentFetchError(this.message);
}

class InvalidPaymentAmount implements Exception {
  final String message;
  InvalidPaymentAmount(this.message);
}

class PaymentProcessingError implements Exception {
  final String message;
  PaymentProcessingError(this.message);
}
