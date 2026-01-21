abstract class FacturaError implements Exception {
  final String message;

  FacturaError(this.message);

  @override
  String toString() => 'FacturaError: $message';
}

class FacturaCreationError extends FacturaError {
  FacturaCreationError(String message) : super(message);
}

class FacturaUpdateError extends FacturaError {
  FacturaUpdateError(String message) : super(message);
}

class FacturaDeletionError extends FacturaError {
  FacturaDeletionError(String message) : super(message);
}

class FacturaFetchError extends FacturaError {
  FacturaFetchError(String message) : super(message);
}
