import 'auth_user.dart';

/// Representa una sesión de autenticación activa
class AuthSession {
  final String token;
  final String? refreshToken;
  final AuthUser user;
  final DateTime expiresAt;
  final DateTime? createdAt;

  const AuthSession({
    required this.token,
    this.refreshToken,
    required this.user,
    required this.expiresAt,
    this.createdAt,
  });

  /// Verifica si la sesión ha expirado
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Verifica si la sesión está activa
  bool get isActive => !isExpired;

  AuthSession copyWith({
    String? token,
    String? refreshToken,
    AuthUser? user,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return AuthSession(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
