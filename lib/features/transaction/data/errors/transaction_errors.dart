class TransactionNotFound implements Exception {}

class TransactionCreateError implements Exception {
  final String message;
  TransactionCreateError(this.message);
}

class TransactionUpdateError implements Exception {
  final String message;
  TransactionUpdateError(this.message);
}

class TransactionDeleteError implements Exception {
  final String message;
  TransactionDeleteError(this.message);
}

class TransactionFetchError implements Exception {
  final String message;
  TransactionFetchError(this.message);
}

class TransactionItemError implements Exception {
  final String message;
  TransactionItemError(this.message);
}

class InvalidTransactionAmount implements Exception {
  final String message;
  InvalidTransactionAmount(this.message);
}
