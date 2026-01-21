/// Excepción base para errores de autenticación
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Error cuando las credenciales son inválidas
class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException([String? message])
      : super(message ?? 'Credenciales inválidas', code: 'invalid-credentials');
}

/// Error cuando el usuario no es encontrado
class UserNotFoundException extends AuthException {
  UserNotFoundException([String? message])
      : super(message ?? 'Usuario no encontrado', code: 'user-not-found');
}

/// Error cuando el email ya está registrado
class EmailAlreadyExistsException extends AuthException {
  EmailAlreadyExistsException([String? message])
      : super(message ?? 'El email ya está registrado', code: 'email-already-exists');
}

/// Error cuando el email no ha sido verificado
class EmailNotVerifiedException extends AuthException {
  EmailNotVerifiedException([String? message])
      : super(message ?? 'El email no ha sido verificado', code: 'email-not-verified');
}

/// Error cuando la sesión ha expirado
class SessionExpiredException extends AuthException {
  SessionExpiredException([String? message])
      : super(message ?? 'La sesión ha expirado', code: 'session-expired');
}

/// Error cuando el token es inválido
class InvalidTokenException extends AuthException {
  InvalidTokenException([String? message])
      : super(message ?? 'Token inválido', code: 'invalid-token');
}

/// Error cuando la contraseña es débil
class WeakPasswordException extends AuthException {
  WeakPasswordException([String? message])
      : super(message ?? 'La contraseña es muy débil', code: 'weak-password');
}

/// Error cuando ocurre un problema de red
class NetworkException extends AuthException {
  NetworkException([String? message])
      : super(message ?? 'Error de conexión', code: 'network-error');
}

/// Error cuando el servidor no responde
class ServerException extends AuthException {
  ServerException([String? message])
      : super(message ?? 'Error del servidor', code: 'server-error');
}
