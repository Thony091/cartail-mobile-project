import 'dart:async';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portafolio_project/config/constants/constants.dart';
import 'package:portafolio_project/config/constants/secure_storage_keys.dart';
import 'package:portafolio_project/config/services/secure_storage_service.dart';

/// Provider para el servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Servicio de autenticación que gestiona:
/// - Comunicación con la API de Better Auth
/// - Gestión automática de cookies para sesiones
/// - Almacenamiento seguro de tokens con flutter_secure_storage
/// - Interceptores para refresh automático de tokens expirados
class AuthService {
  late final Dio _dio;
  late final PersistCookieJar _cookieJar;
  bool _isInitialized = false;

  /// URL base de la API de Better Auth
  static final String _baseUrl = Enviroment.baseUrl;
  // static const String _baseUrl = 'https://agendashop.instatunnel.my';
  // static const String _originHeader = 'https://agendashop.fabersoft.cl';

  /// Keys para almacenamiento seguro de tokens
  static const String _tokenKey = 'better_auth_token';
  static const String _tokenExpiresKey = 'better_auth_token_expires';
  static const String _userIdKey = 'better_auth_user_id';
  static const String _accountIdKey = 'better_auth_account_id';

  /// Instancia de FlutterSecureStorage para almacenamiento seguro (centralizada)
  final _secureStorage = SecureStorageService.instance;

  /// Token actual en memoria (para acceso rápido)
  String? _currentToken;

  /// Información necesaria para refresh
  String? _currentUserId;
  String? _currentAccountId;

  /// Fecha de expiración del token actual
  DateTime? _tokenExpiresAt;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        contentType: 'application/json',
        // headers: {'Origin': _originHeader},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) {
          // Acepta todos los status < 500 para manejarlos manualmente
          return status != null && status < 500;
        },
      ),
    );
  }

  /// Inicializa el servicio de autenticación.
  /// Debe llamarse antes de usar cualquier método.
  /// Configura: SecureStorage, CookieJar, interceptores de auth y logging.
  Future<void> init() async {
    if (_isInitialized) return;

    // Cargar tokens guardados de forma segura
    await _loadStoredTokens();

    // Configurar cookie jar para persistencia de cookies
    final appDocDir = await getApplicationDocumentsDirectory();
    final String path = appDocDir.path;
    _cookieJar = PersistCookieJar(storage: FileStorage("$path/.cookies/"));

    // Agregar interceptor de cookies
    _dio.interceptors.add(CookieManager(_cookieJar));

    // Agregar interceptor de autenticación y refresh automático
    _dio.interceptors.add(_AuthInterceptor(this));

    // Agregar logging en modo debug
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    _isInitialized = true;
    debugPrint('AuthService inicializado correctamente');
  }

  /// Carga los tokens almacenados de forma segura con FlutterSecureStorage.
  /// Se llama automáticamente durante init().
  Future<void> _loadStoredTokens() async {
    _currentToken = await _secureStorage.read(key: _tokenKey);
    _currentUserId = await _secureStorage.read(key: _userIdKey);
    _currentAccountId = await _secureStorage.read(key: _accountIdKey);

    final expiresString = await _secureStorage.read(key: _tokenExpiresKey);
    if (expiresString != null) {
      _tokenExpiresAt = DateTime.tryParse(expiresString);
    }

    debugPrint('Tokens cargados: token=${_currentToken != null}, userId=$_currentUserId');
  }

  /// Guarda los tokens de forma segura con FlutterSecureStorage.
  /// [token] - Token de acceso (requerido)
  /// [userId] - ID del usuario (opcional, mantiene el anterior si no se proporciona)
  /// [accountId] - ID de la cuenta (opcional, mantiene el anterior si no se proporciona)
  /// [expiresAt] - Fecha de expiración del token (opcional)
  Future<void> _saveTokens({
    required String token,
    String? userId,
    String? accountId,
    DateTime? expiresAt,
  }) async {
    _currentToken = token;
    _currentUserId = userId ?? _currentUserId;
    _currentAccountId = accountId ?? _currentAccountId;
    _tokenExpiresAt = expiresAt;

    await _secureStorage.write(key: _tokenKey, value: token);
    if (userId != null) {
      await _secureStorage.write(key: _userIdKey, value: userId);
    }
    if (accountId != null) {
      await _secureStorage.write(key: _accountIdKey, value: accountId);
    }
    if (expiresAt != null) {
      await _secureStorage.write(
        key: _tokenExpiresKey,
        value: expiresAt.toIso8601String(),
      );
    }

    debugPrint('Tokens guardados de forma segura');
  }

  /// Limpia todos los tokens almacenados (memoria y SecureStorage).
  /// Se llama automáticamente al cerrar sesión o cuando el refresh falla.
  Future<void> _clearTokens() async {
    _currentToken = null;
    _currentUserId = null;
    _currentAccountId = null;
    _tokenExpiresAt = null;

    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _accountIdKey);
    await _secureStorage.delete(key: _tokenExpiresKey);

    debugPrint('Tokens eliminados de forma segura');
  }

  /// Helper getter para asegurar que el servicio esté inicializado antes de usar.
  /// Retorna la instancia de Dio configurada.
  Future<Dio> get client async {
    if (!_isInitialized) await init();
    return _dio;
  }

  /// Obtiene el token actual (null si no hay sesión activa)
  String? get currentToken => _currentToken;

  /// Verifica si hay una sesión activa (token en memoria)
  bool get hasActiveSession => _currentToken != null;

  /// Verifica si el token ha expirado basándose en la fecha de expiración guardada
  bool get isTokenExpired {
    if (_tokenExpiresAt == null) return true;
    return DateTime.now().isAfter(_tokenExpiresAt!);
  }

  // ============================================================
  // ENDPOINTS DE AUTENTICACIÓN
  // ============================================================

  /// Inicia sesión con email y contraseña.
  ///
  /// Endpoint: POST /api/auth/sign-in/email
  ///
  /// [email] - Email del usuario
  /// [password] - Contraseña del usuario
  /// [callbackURL] - URL de callback opcional
  /// [rememberMe] - Si true, la sesión persiste (default: true)
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// {
  ///   "redirect": false,
  ///   "token": "string",
  ///   "url": null,
  ///   "user": {
  ///     "id": "string",
  ///     "name": "string",
  ///     "email": "string",
  ///     "emailVerified": false,
  ///     "image": "string",
  ///     "role": "string",
  ///     "banned": false,
  ///     ...
  ///   }
  /// }
  /// ```
  Future<Response> signInWithEmail({
    required String email,
    required String password,
    String? callbackURL = '',
    bool? rememberMe,
  }) async {
    final dio = await client;
    final fcmToken = await _secureStorage.read(key: secureStorageFcmTokenKey);
    final requestBody = <String, dynamic>{
      'email': email,
      'password': password,
      'callbackURL': callbackURL,
      'rememberMe': rememberMe ?? true,
    };
    if (fcmToken != null) {
      requestBody['fcmToken'] = fcmToken;
    }
    final response = await dio.post(
      '/auth/sign-in/email',
      data: requestBody,
    );
    // final newToken = response.headers.value('set-auth-jwt');
    // final cookies = response.headers['set-cookie'];

    // Si el login es exitoso, guardar el token automáticamente
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (token != null) {
        await _saveTokens(
          token: token,
          userId: user?['id'] as String?,
        );

        await _secureStorage.write(
          key: secureStorageAccessTokenKey,
          value: token,
        );
      }
    }

    return response;
  }

  /// Registra un nuevo usuario con email y contraseña.
  ///
  /// Endpoint: POST /api/auth/sign-up/email
  ///
  /// [name] - Nombre del usuario
  /// [email] - Email del usuario
  /// [password] - Contraseña del usuario
  /// [image] - URL de imagen de perfil (opcional)
  /// [callbackURL] - URL de callback opcional
  /// [rememberMe] - Si true, la sesión persiste (default: true)
  ///
  /// Respuesta exitosa (200/201):
  /// ```json
  /// {
  ///   "token": null,
  ///   "user": {
  ///     "id": "string",
  ///     "email": "hello@example.com",
  ///     "name": "string",
  ///     "image": null,
  ///     "emailVerified": true,
  ///     "createdAt": "2026-01-15T23:35:33.793Z",
  ///     "updatedAt": "2026-01-15T23:35:33.793Z"
  ///   }
  /// }
  /// ```
  Future<Response> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String? image,
    String? callbackURL,
    bool? rememberMe,
  }) async {
    final dio = await client;
    final response = await dio.post(
      '/auth/sign-up/email',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'image': image ?? '',
        'callbackURL': callbackURL ?? '',
        'rememberMe': rememberMe ?? true,
      },
    );

    // Guardar token si viene en la respuesta
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>?;
      final token = data?['token'] as String?;
      final user = data?['user'] as Map<String, dynamic>?;

      if (token != null) {
        await _saveTokens(
          token: token,
          userId: user?['id'] as String?,
        );
      }
    }

    return response;
  }

  /// Cierra la sesión actual del usuario.
  /// Limpia tokens locales y cookies automáticamente.
  ///
  /// Endpoint: POST /api/auth/sign-out
  ///
  /// Respuesta exitosa (200): { "success": true }
  Future<Response> signOut() async {
    final dio = await client;
    final response = await dio.post(
      '/auth/sign-out',
      data: {},
      options: _authOptions(),
    );

    // Limpiar tokens y cookies independientemente del resultado
    await _clearTokens();
    await clearCookies();

    return response;
  }

  /// Obtiene la sesión actual del usuario autenticado.
  /// Útil para verificar si la sesión sigue activa.
  ///
  /// Endpoint: GET /api/auth/get-session
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// {
  ///   "session": {
  ///     "id": "string",
  ///     "expiresAt": "2026-01-15T23:35:33.793Z",
  ///     "token": "string",
  ///     "createdAt": "Generated at runtime",
  ///     "updatedAt": "2026-01-15T23:35:33.793Z",
  ///     "ipAddress": "string",
  ///     "userAgent": "string",
  ///     "userId": "string",
  ///     "impersonatedBy": "string"
  ///   },
  ///   "user": {
  ///     "id": "string",
  ///     "name": "string",
  ///     "email": "string",
  ///     "emailVerified": false,
  ///     "image": "string",
  ///     "role": "string",
  ///     "banned": false,
  ///     "banReason": "string",
  ///     "banExpires": "2026-01-15T23:35:33.793Z"
  ///   }
  /// }
  /// ```
  Future<Response> getSession() async {
    final dio = await client;

    try {
      final response = await dio.get(
        '/auth/get-session',
        options: _authOptions(),
      );

      // Extraer el nuevo token del header personalizado
      final newToken = response.headers.value('set-auth-jwt');

      if (newToken != null && newToken.isNotEmpty) {
        _currentToken = newToken;
        await _secureStorage.write(key: jwtStorageAccessTokenKey, value: newToken);
        debugPrint('🔐 Token actualizado desde header set-auth-jwt');
      } else {
        debugPrint('⚠️ Header set-auth-jwt no encontrado');
      }

      return response;
    } on DioException catch (e) {
      debugPrint('❌ Error al obtener sesión: ${e.response?.statusCode} ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error inesperado en getSession: $e');
      rethrow;
    }
  }

  /// Verifica el email del usuario con un token enviado por correo.
  ///
  /// Endpoint: GET /api/auth/verify-email?token=&callbackURL=
  ///
  /// [token] - Token de verificación recibido por email
  /// [callbackURL] - URL de callback opcional
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// {
  ///   "user": { ... },
  ///   "status": true
  /// }
  /// ```
  Future<Response> verifyEmail({
    required String token,
    String? callbackURL,
  }) async {
    final dio = await client;
    return dio.get(
      '/auth/verify-email',
      queryParameters: {
        'token': token,
        'callbackURL': callbackURL ?? '',
      },
      options: _authOptions(),
    );
  }

  /// Envía un email de verificación al usuario.
  ///
  /// Endpoint: POST /api/auth/send-verification-email
  ///
  /// [email] - Email del usuario
  /// [callbackURL] - URL de callback opcional
  ///
  /// Respuesta exitosa (200): { "status": true }
  Future<Response> sendVerificationEmail({
    required String email,
    String? callbackURL,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/send-verification-email',
      data: {
        'email': email,
        'callbackURL': callbackURL ?? '',
      },
      options: _authOptions(),
    );
  }

  /// Solicita un email para restablecer la contraseña.
  ///
  /// Endpoint: POST /api/auth/request-password-reset
  ///
  /// [email] - Email del usuario
  /// [redirectTo] - URL de redirección opcional
  ///
  /// Respuesta exitosa (200): { "status": true, "message": "string" }
  Future<Response> requestPasswordReset({
    required String email,
    String? redirectTo,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/request-password-reset',
      data: {
        'email': email,
        'redirectTo': redirectTo,
      },
      options: _authOptions(),
    );
  }

  /// Restablece la contraseña usando un token recibido por email.
  ///
  /// Endpoint: POST /api/auth/reset-password
  ///
  /// [newPassword] - Nueva contraseña
  /// [token] - Token de restablecimiento
  ///
  /// Respuesta exitosa (200): { "status": true }
  Future<Response> resetPassword({
    required String newPassword,
    String? token,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/reset-password',
      data: {
        'newPassword': newPassword,
        'token': token,
      },
      options: _authOptions(),
    );
  }

  /// Verifica si un token de restablecimiento de contraseña es válido.
  ///
  /// Endpoint: GET /api/auth/reset-password/{token}?callbackURL=
  ///
  /// [token] - Token de restablecimiento
  /// [callbackURL] - URL de callback opcional
  ///
  /// Respuesta exitosa (200): { "token": "string" }
  Future<Response> verifyResetPasswordToken({
    required String token,
    String? callbackURL,
  }) async {
    final dio = await client;
    return dio.get(
      '/auth/reset-password/$token',
      queryParameters: {'callbackURL': callbackURL ?? ''},
      options: _authOptions(),
    );
  }

  /// Cambia la contraseña del usuario autenticado.
  ///
  /// Endpoint: POST /api/auth/change-password
  ///
  /// [newPassword] - Nueva contraseña
  /// [currentPassword] - Contraseña actual
  /// [revokeOtherSessions] - Si true, revoca las demás sesiones
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// {
  ///   "token": null,
  ///   "user": { ... }
  /// }
  /// ```
  Future<Response> changePassword({
    required String newPassword,
    required String currentPassword,
    bool? revokeOtherSessions,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/change-password',
      data: {
        'newPassword': newPassword,
        'currentPassword': currentPassword,
        'revokeOtherSessions': revokeOtherSessions,
      },
      options: _authOptions(),
    );
  }

  /// Cambia el email del usuario autenticado.
  ///
  /// Endpoint: POST /api/auth/change-email
  ///
  /// [newEmail] - Nuevo email
  /// [callbackURL] - URL de callback opcional
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// {
  ///   "user": { ... },
  ///   "status": true,
  ///   "message": "Email updated"
  /// }
  /// ```
  Future<Response> changeEmail({
    required String newEmail,
    String? callbackURL,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/change-email',
      data: {
        'newEmail': newEmail,
        'callbackURL': callbackURL,
      },
      options: _authOptions(),
    );
  }

  /// Actualiza el perfil del usuario (nombre e imagen).
  ///
  /// Endpoint: POST /api/auth/update-user
  ///
  /// [name] - Nuevo nombre (opcional)
  /// [image] - Nueva URL de imagen (opcional)
  ///
  /// Respuesta exitosa (200): { "user": { ... } }
  Future<Response> updateUser({
    String? name,
    String? image,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/update-user',
      data: {
        'name': name ?? '',
        'image': image,
      },
      options: _authOptions(),
    );
  }

  /// Elimina la cuenta del usuario.
  /// Limpia tokens y cookies automáticamente si la eliminación es exitosa.
  ///
  /// Endpoint: POST /api/auth/delete-user
  ///
  /// [password] - Contraseña del usuario para confirmar
  /// [callbackURL] - URL de callback opcional
  /// [token] - Token de confirmación opcional
  ///
  /// Respuesta exitosa (200): { "success": true, "message": "User deleted" }
  Future<Response> deleteUser({
    String? callbackURL,
    String? password,
    String? token,
  }) async {
    final dio = await client;
    final response = await dio.post(
      '/auth/delete-user',
      data: {
        'callbackURL': callbackURL ?? '',
        'password': password ?? '',
        'token': token ?? '',
      },
      options: _authOptions(),
    );

    // Limpiar sesión si la eliminación fue exitosa
    if (response.statusCode == 200) {
      await _clearTokens();
      await clearCookies();
    }

    return response;
  }

  /// Obtiene información detallada de la cuenta del usuario.
  ///
  /// Endpoint: GET /api/auth/account-info
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// {
  ///   "user": {
  ///     "id": "string",
  ///     "name": "string",
  ///     "email": "string",
  ///     "image": "string",
  ///     "emailVerified": true
  ///   },
  ///   "data": { ... }
  /// }
  /// ```
  Future<Response> accountInfo() async {
    final dio = await client;
    return dio.get(
      '/auth/account-info',
      options: _authOptions(),
    );
  }

  // ============================================================
  // GESTIÓN DE SESIONES
  // ============================================================

  /// Lista todas las sesiones activas del usuario.
  /// Útil para mostrar dispositivos conectados.
  ///
  /// Endpoint: GET /api/auth/list-sessions
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// [
  ///   {
  ///     "id": "string",
  ///     "expiresAt": "2026-01-15T23:35:33.793Z",
  ///     "token": "string",
  ///     "ipAddress": "string",
  ///     "userAgent": "string",
  ///     "userId": "string"
  ///   }
  /// ]
  /// ```
  Future<Response> listSessions() async {
    final dio = await client;
    return dio.get(
      '/auth/list-sessions',
      options: _authOptions(),
    );
  }

  /// Revoca una sesión específica por su token.
  ///
  /// Endpoint: POST /api/auth/revoke-session
  ///
  /// [token] - Token de la sesión a revocar
  ///
  /// Respuesta exitosa (200): { "status": true }
  Future<Response> revokeSession({required String token}) async {
    final dio = await client;
    return dio.post(
      '/auth/revoke-session',
      data: {'token': token},
      options: _authOptions(),
    );
  }

  /// Revoca TODAS las sesiones del usuario (incluyendo la actual).
  /// Limpia tokens locales automáticamente.
  ///
  /// Endpoint: POST /api/auth/revoke-sessions
  ///
  /// Respuesta exitosa (200): { "status": true }
  Future<Response> revokeSessions() async {
    final dio = await client;
    final response = await dio.post(
      '/auth/revoke-sessions',
      data: {},
      options: _authOptions(),
    );

    // Limpiar tokens locales ya que todas las sesiones fueron revocadas
    await _clearTokens();
    await clearCookies();

    return response;
  }

  /// Revoca todas las sesiones del usuario EXCEPTO la actual.
  /// Útil para "cerrar sesión en otros dispositivos".
  ///
  /// Endpoint: POST /api/auth/revoke-other-sessions
  ///
  /// Respuesta exitosa (200): { "status": true }
  Future<Response> revokeOtherSessions() async {
    final dio = await client;
    return dio.post(
      '/auth/revoke-other-sessions',
      data: {},
      options: _authOptions(),
    );
  }

  // ============================================================
  // GESTIÓN DE TOKENS
  // ============================================================

  /// Refresca el token de acceso.
  /// Se llama automáticamente por el interceptor cuando el token expira.
  ///
  /// Endpoint: POST /api/auth/refresh-token
  ///
  /// [providerId] - ID del proveedor (default: "credential")
  /// [accountId] - ID de la cuenta
  /// [userId] - ID del usuario
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// {
  ///   "tokenType": "string",
  ///   "idToken": "string",
  ///   "accessToken": "string",
  ///   "refreshToken": "string",
  ///   "accessTokenExpiresAt": "2026-01-15T23:35:33.793Z",
  ///   "refreshTokenExpiresAt": "2026-01-15T23:35:33.793Z"
  /// }
  /// ```
  Future<Response> refreshToken({
    String? providerId,
    String? accountId,
    String? userId,
  }) async {
    final dio = await client;
    final response = await dio.post(
      '/auth/refresh-token',
      data: {
        'providerId': providerId ?? 'credential',
        'accountId': accountId ?? _currentAccountId,
        'userId': userId ?? _currentUserId,
      },
      options: _authOptions(),
    );

    // Guardar nuevos tokens si el refresh fue exitoso
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final expiresAtStr = data['accessTokenExpiresAt'] as String?;

      if (accessToken != null) {
        await _saveTokens(
          token: accessToken,
          expiresAt: expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null,
        );
      }
    }

    return response;
  }

  /// Obtiene un nuevo token de acceso.
  /// Similar a refreshToken pero con diferentes parámetros.
  ///
  /// Endpoint: POST /api/auth/get-access-token
  ///
  /// Respuesta exitosa (200): misma estructura que refresh-token
  Future<Response> getAccessToken({
    String? providerId,
    String? accountId,
    String? userId,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/get-access-token',
      data: {
        'providerId': providerId ?? '',
        'accountId': accountId,
        'userId': userId,
      },
      options: _authOptions(),
    );
  }

  // ============================================================
  // CUENTAS SOCIALES
  // ============================================================

  /// Inicia sesión con un proveedor social (Google, Apple, etc.).
  ///
  /// Endpoint: POST /api/auth/sign-in/social
  ///
  /// [provider] - Nombre del proveedor ("google", "apple", etc.)
  /// [idToken] - Token del proveedor social
  /// [callbackURL] - URL de callback
  /// [newUserCallbackURL] - URL para nuevos usuarios
  /// [errorCallbackURL] - URL de error
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// {
  ///   "token": "string",
  ///   "user": { ... },
  ///   "url": "string",
  ///   "redirect": false
  /// }
  /// ```
  Future<Response> signInSocial({
    required String provider,
    Map<String, dynamic>? idToken,
    String? callbackURL,
    String? newUserCallbackURL,
    String? errorCallbackURL,
    bool? disableRedirect,
    bool? requestSignUp,
    String? loginHint,
    List<String>? scopes,
    Map<String, dynamic>? additionalData,
  }) async {
    final dio = await client;
    final response = await dio.post(
      '/auth/sign-in/social',
      data: {
        'provider': provider,
        'idToken': idToken ?? {'token': ''},
        'callbackURL': callbackURL,
        'newUserCallbackURL': newUserCallbackURL,
        'errorCallbackURL': errorCallbackURL,
        'disableRedirect': disableRedirect,
        'requestSignUp': requestSignUp,
        'loginHint': loginHint,
        'scopes': scopes,
        'additionalData': additionalData,
      },
      options: _authOptions(),
    );

    // Guardar token si viene en la respuesta
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (token != null) {
        await _saveTokens(
          token: token,
          userId: user?['id'] as String?,
        );
      }
    }

    return response;
  }

  /// Vincula una cuenta social al usuario autenticado.
  ///
  /// Endpoint: POST /api/auth/link-social
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// {
  ///   "url": "string",
  ///   "redirect": true,
  ///   "status": true
  /// }
  /// ```
  Future<Response> linkSocial({
    required String provider,
    Map<String, dynamic>? idToken,
    String? callbackURL,
    String? errorCallbackURL,
    bool? disableRedirect,
    bool? requestSignUp,
    List<String>? scopes,
    Map<String, dynamic>? additionalData,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/link-social',
      data: {
        'provider': provider,
        'idToken': idToken ?? {'token': '', 'nonce': null},
        'callbackURL': callbackURL,
        'errorCallbackURL': errorCallbackURL,
        'disableRedirect': disableRedirect,
        'requestSignUp': requestSignUp,
        'scopes': scopes,
        'additionalData': additionalData,
      },
      options: _authOptions(),
    );
  }

  /// Lista las cuentas sociales vinculadas al usuario.
  ///
  /// Endpoint: GET /api/auth/list-accounts
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// [
  ///   {
  ///     "id": "string",
  ///     "providerId": "string",
  ///     "createdAt": "2026-01-15T23:35:33.793Z",
  ///     "accountId": "string",
  ///     "userId": "string",
  ///     "scopes": ["string"]
  ///   }
  /// ]
  /// ```
  Future<Response> listAccounts() async {
    final dio = await client;
    return dio.get(
      '/auth/list-accounts',
      options: _authOptions(),
    );
  }

  /// Desvincula una cuenta social del usuario.
  ///
  /// Endpoint: POST /api/auth/unlink-account
  ///
  /// [providerId] - ID del proveedor a desvincular
  /// [accountId] - ID de la cuenta a desvincular (opcional)
  ///
  /// Respuesta exitosa (200): { "status": true }
  Future<Response> unlinkAccount({
    required String providerId,
    String? accountId,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/unlink-account',
      data: {
        'providerId': providerId,
        'accountId': accountId,
      },
      options: _authOptions(),
    );
  }

  // ============================================================
  // ADMINISTRACIÓN DE USUARIOS (Solo Admins)
  // ============================================================

  /// Asigna un rol a un usuario.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: POST /api/auth/admin/set-role
  ///
  /// [userId] - ID del usuario
  /// [role] - Nuevo rol ("admin", "operator", "user", etc.)
  ///
  /// Respuesta exitosa (200): { "user": { ... } }
  Future<Response> adminSetRole({
    required String userId,
    required String role,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/admin/set-role',
      data: {
        'userId': userId,
        'role': role,
      },
      options: _authOptions(),
    );
  }

  /// Obtiene información de un usuario por su ID.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: GET /api/auth/admin/get-user?id=
  ///
  /// [id] - ID del usuario
  ///
  /// Respuesta exitosa (200): { "user": { ... } }
  Future<Response> adminGetUser({required String id}) async {
    final dio = await client;
    return dio.get(
      '/auth/admin/get-user',
      queryParameters: {'id': id},
      options: _authOptions(),
    );
  }

  /// Crea un nuevo usuario desde el panel de admin.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: POST /api/auth/admin/create-user
  ///
  /// [email] - Email del nuevo usuario
  /// [password] - Contraseña del nuevo usuario
  /// [name] - Nombre del nuevo usuario
  /// [role] - Rol del nuevo usuario (opcional)
  /// [data] - Datos adicionales (opcional)
  ///
  /// Respuesta exitosa (200): { "user": { ... } }
  Future<Response> adminCreateUser({
    required String email,
    required String password,
    required String name,
    String? role,
    Map<String, dynamic>? data,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/admin/create-user',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
        'data': data,
      },
      options: _authOptions(),
    );
  }

  /// Actualiza un usuario desde el panel de admin.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: POST /api/auth/admin/update-user
  ///
  /// [userId] - ID del usuario a actualizar
  /// [data] - Datos a actualizar (nombre, email, etc.)
  ///
  /// Respuesta exitosa (200): { "user": { ... } }
  Future<Response> adminUpdateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/admin/update-user',
      data: {
        'userId': userId,
        'data': data,
      },
      options: _authOptions(),
    );
  }

  /// Lista usuarios con paginación y filtros.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: GET /api/auth/admin/list-users
  ///
  /// Parámetros de búsqueda y filtrado:
  /// [searchValue] - Valor a buscar
  /// [searchField] - Campo en el que buscar
  /// [searchOperator] - Operador de búsqueda
  /// [limit] - Límite de resultados
  /// [offset] - Desplazamiento para paginación
  /// [sortBy] - Campo por el cual ordenar
  /// [sortDirection] - Dirección del ordenamiento ("asc" o "desc")
  /// [filterField] - Campo para filtrar
  /// [filterValue] - Valor del filtro
  /// [filterOperator] - Operador del filtro
  ///
  /// Respuesta exitosa (200):
  /// ```json
  /// {
  ///   "users": [ { ... } ],
  ///   "total": 100,
  ///   "limit": 10,
  ///   "offset": 0
  /// }
  /// ```
  Future<Response> adminListUsers({
    String? searchValue,
    String? searchField,
    String? searchOperator,
    int? limit,
    int? offset,
    String? sortBy,
    String? sortDirection,
    String? filterField,
    String? filterValue,
    String? filterOperator,
  }) async {
    final dio = await client;
    return dio.get(
      '/auth/admin/list-users',
      queryParameters: {
        if (searchValue != null) 'searchValue': searchValue,
        if (searchField != null) 'searchField': searchField,
        if (searchOperator != null) 'searchOperator': searchOperator,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortDirection != null) 'sortDirection': sortDirection,
        if (filterField != null) 'filterField': filterField,
        if (filterValue != null) 'filterValue': filterValue,
        if (filterOperator != null) 'filterOperator': filterOperator,
      },
      options: _authOptions(),
    );
  }

  /// Lista las sesiones activas de un usuario específico.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: POST /api/auth/admin/list-user-sessions
  ///
  /// [userId] - ID del usuario
  ///
  /// Respuesta exitosa (200): { "sessions": [ { ... } ] }
  Future<Response> adminListUserSessions({required String userId}) async {
    final dio = await client;
    return dio.post(
      '/auth/admin/list-user-sessions',
      data: {'userId': userId},
      options: _authOptions(),
    );
  }

  /// Banea a un usuario.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: POST /api/auth/admin/ban-user
  ///
  /// [userId] - ID del usuario a banear
  /// [banReason] - Razón del baneo (opcional)
  /// [banExpiresIn] - Tiempo en segundos hasta que expire el ban (opcional)
  ///
  /// Respuesta exitosa (200): { "user": { ... } }
  Future<Response> adminBanUser({
    required String userId,
    String? banReason,
    int? banExpiresIn,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/admin/ban-user',
      data: {
        'userId': userId,
        'banReason': banReason,
        'banExpiresIn': banExpiresIn,
      },
      options: _authOptions(),
    );
  }

  /// Desbanea a un usuario.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: POST /api/auth/admin/unban-user
  ///
  /// [userId] - ID del usuario a desbanear
  ///
  /// Respuesta exitosa (200): { "user": { ... } }
  Future<Response> adminUnbanUser({required String userId}) async {
    final dio = await client;
    return dio.post(
      '/auth/admin/unban-user',
      data: {'userId': userId},
      options: _authOptions(),
    );
  }

  /// Inicia una sesión de impersonación como otro usuario.
  /// Requiere permisos de administrador.
  /// ADVERTENCIA: Use con precaución, solo para debugging/soporte.
  ///
  /// Endpoint: POST /api/auth/admin/impersonate-user
  ///
  /// [userId] - ID del usuario a impersonar
  ///
  /// Respuesta exitosa (200): { "session": { ... }, "user": { ... } }
  Future<Response> adminImpersonateUser({required String userId}) async {
    final dio = await client;
    final response = await dio.post(
      '/auth/admin/impersonate-user',
      data: {'userId': userId},
      options: _authOptions(),
    );

    // Si la impersonación es exitosa, guardar el nuevo token
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final session = data['session'] as Map<String, dynamic>?;
      final user = data['user'] as Map<String, dynamic>?;

      if (session != null && session['token'] != null) {
        await _saveTokens(
          token: session['token'] as String,
          userId: user?['id'] as String?,
        );
      }
    }

    return response;
  }

  /// Detiene la sesión de impersonación y vuelve al usuario admin.
  /// Requiere estar en una sesión de impersonación.
  ///
  /// Endpoint: POST /api/auth/admin/stop-impersonating
  ///
  /// Respuesta exitosa (200): { "message": "string" }
  Future<Response> adminStopImpersonating() async {
    final dio = await client;
    return dio.post(
      '/auth/admin/stop-impersonating',
      options: _authOptions(),
    );
  }

  /// Revoca una sesión específica de un usuario.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: POST /api/auth/admin/revoke-user-session
  ///
  /// [sessionToken] - Token de la sesión a revocar
  ///
  /// Respuesta exitosa (200): { "success": true }
  Future<Response> adminRevokeUserSession({
    required String sessionToken,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/admin/revoke-user-session',
      data: {'sessionToken': sessionToken},
      options: _authOptions(),
    );
  }

  /// Revoca todas las sesiones de un usuario.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: POST /api/auth/admin/revoke-user-sessions
  ///
  /// [userId] - ID del usuario cuyas sesiones se revocarán
  ///
  /// Respuesta exitosa (200): { "success": true }
  Future<Response> adminRevokeUserSessions({required String userId}) async {
    final dio = await client;
    return dio.post(
      '/auth/admin/revoke-user-sessions',
      data: {'userId': userId},
      options: _authOptions(),
    );
  }

  /// Establece una nueva contraseña para un usuario.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: POST /api/auth/admin/set-user-password
  ///
  /// [userId] - ID del usuario
  /// [newPassword] - Nueva contraseña
  ///
  /// Respuesta exitosa (200): { "status": true }
  Future<Response> adminSetUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/admin/set-user-password',
      data: {
        'userId': userId,
        'newPassword': newPassword,
      },
      options: _authOptions(),
    );
  }

  /// Verifica si el usuario actual tiene ciertos permisos.
  /// Requiere permisos de administrador.
  ///
  /// Endpoint: POST /api/auth/admin/has-permission
  ///
  /// [permissions] - Mapa de permisos a verificar
  ///
  /// Respuesta exitosa (200): { "success": true } o { "error": "string", "success": false }
  Future<Response> adminHasPermission({
    required Map<String, dynamic> permissions,
  }) async {
    final dio = await client;
    return dio.post(
      '/auth/admin/has-permission',
      data: {'permissions': permissions},
      options: _authOptions(),
    );
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  /// Verifica que el servicio de auth esté funcionando.
  /// Útil para health checks.
  ///
  /// Endpoint: GET /api/auth/ok
  ///
  /// Respuesta exitosa (200): { "ok": true }
  Future<Response> healthCheck() async {
    final dio = await client;
    return dio.get('/auth/ok');
  }

  /// Obtiene el último error del servicio de auth.
  ///
  /// Endpoint: GET /api/auth/error
  ///
  /// Respuesta exitosa (200): "string" (mensaje de error)
  Future<Response> getError() async {
    final dio = await client;
    return dio.get('/auth/error');
  }

  /// Limpia todas las cookies almacenadas.
  /// Útil para logout completo.
  Future<void> clearCookies() async {
    if (_isInitialized) {
      await _cookieJar.deleteAll();
      debugPrint('Cookies eliminadas');
    }
  }

  /// Genera opciones de request con el header de autorización Bearer.
  /// Retorna Options vacías si no hay token.
  Options _authOptions() {
    if (_currentToken != null) {
      return Options(
        headers: {
          'Authorization': 'Bearer $_currentToken',
          // 'Origin': _originHeader,
        },
      );
    }
    return Options(
      headers: {/*'Origin': _originHeader*/}
    );
  }

  /// Intenta refrescar el token automáticamente.
  /// Retorna true si el refresh fue exitoso.
  ///
  /// Este método es llamado automáticamente por el interceptor
  /// cuando recibe un error 401.
  Future<bool> tryRefreshToken() async {
    if (_currentUserId == null) {
      debugPrint('No se puede refrescar: userId no disponible');
      return false;
    }

    try {
      final response = await refreshToken();
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error refrescando token: $e');
      return false;
    }
  }
}

/// Interceptor para manejar autenticación automática y refresh de tokens.
///
/// Funcionalidades:
/// - Agrega el header Authorization automáticamente a todas las requests
/// - Detecta errores 401 (Unauthorized) y reintenta con refresh
/// - Encola requests mientras se refresca el token
/// - Reintenta requests pendientes después de un refresh exitoso
class _AuthInterceptor extends Interceptor {
  final AuthService _authService;
  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  _AuthInterceptor(this._authService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Agregar token automáticamente si está disponible y no se ha agregado
    if (_authService._currentToken != null &&
        !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer ${_authService._currentToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si el error es 401 (Unauthorized), intentar refrescar el token
    if (err.response?.statusCode == 401 && _authService._currentUserId != null) {
      // Evitar múltiples refreshes simultáneos
      if (_isRefreshing) {
        // Encolar la request para reintentar después del refresh
        _pendingRequests.add(_RetryRequest(err.requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      try {
        final refreshSuccess = await _authService.tryRefreshToken();

        if (refreshSuccess) {
          debugPrint('Token refrescado exitosamente, reintentando request');

          // Reintentar la request original con el nuevo token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${_authService._currentToken}';

          final dio = await _authService.client;
          final response = await dio.fetch(opts);
          handler.resolve(response);

          // Reintentar requests pendientes
          for (final pending in _pendingRequests) {
            pending.options.headers['Authorization'] =
                'Bearer ${_authService._currentToken}';
            final retryResponse = await dio.fetch(pending.options);
            pending.handler.resolve(retryResponse);
          }
          _pendingRequests.clear();
        } else {
          debugPrint('Refresh falló, propagando error 401');
          // Limpiar sesión ya que el refresh falló
          await _authService._clearTokens();
          handler.next(err);

          // Rechazar requests pendientes
          for (final pending in _pendingRequests) {
            pending.handler.reject(err);
          }
          _pendingRequests.clear();
        }
      } catch (e) {
        debugPrint('Error durante refresh: $e');
        handler.next(err);

        for (final pending in _pendingRequests) {
          pending.handler.reject(err);
        }
        _pendingRequests.clear();
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}

/// Clase auxiliar para encolar requests pendientes durante el refresh de token.
class _RetryRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _RetryRequest(this.options, this.handler);
}
