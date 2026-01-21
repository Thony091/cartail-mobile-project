
class ConnectionTimeout implements Exception {}
class InvalidToken implements Exception {}
class WrongCredentials implements Exception {}

/// Clase para personalizar errores, implementa la clase Exception
class CustomError implements Exception {
  /// Mensaje descriptivo del error.
  final String message;

  /// Constructor que inicializa el error con un mensaje.
  CustomError(this.message);
}

