import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_session.dart';

/// Servicio para almacenar y recuperar tokens de autenticación
class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _tokenExpiresAtKey = 'auth_token_expires_at';

  final SharedPreferences _prefs;

  TokenStorageService(this._prefs);

  /// Guarda la sesión en el almacenamiento local
  Future<void> saveSession(AuthSession session) async {
    await _prefs.setString(_tokenKey, session.token);
    if (session.refreshToken != null) {
      await _prefs.setString(_refreshTokenKey, session.refreshToken!);
    }
    await _prefs.setString(
      _tokenExpiresAtKey,
      session.expiresAt.toIso8601String(),
    );
  }

  /// Obtiene el token almacenado
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  /// Obtiene el refresh token almacenado
  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }

  /// Obtiene la fecha de expiración del token
  Future<DateTime?> getTokenExpiresAt() async {
    final expiresAtStr = _prefs.getString(_tokenExpiresAtKey);
    if (expiresAtStr == null) return null;
    return DateTime.tryParse(expiresAtStr);
  }

  /// Elimina la sesión del almacenamiento
  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_tokenExpiresAtKey);
  }

  /// Verifica si hay un token almacenado
  Future<bool> hasToken() async {
    return _prefs.containsKey(_tokenKey);
  }

  /// Verifica si el token ha expirado
  Future<bool> isTokenExpired() async {
    final expiresAt = await getTokenExpiresAt();
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt);
  }
}
