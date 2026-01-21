import 'package:dio/dio.dart';
import '../../../../config/services/auth_service.dart';
import '../../domain/errors/auth_exceptions.dart';
import '../models/better_auth_response_models.dart';
import '../models/better_auth_user_model.dart';
import 'better_auth_datasource.dart';

/// Implementación del datasource de Better Auth usando AuthService.
///
/// Esta clase actúa como puente entre el dominio y el servicio de autenticación,
/// convirtiendo las respuestas HTTP en modelos de dominio y manejando errores.
///
/// Características:
/// - Usa AuthService para todas las llamadas HTTP (Dio + CookieManager)
/// - Convierte respuestas JSON a modelos tipados
/// - Transforma errores HTTP en excepciones de dominio (AuthException)
/// - Gestión automática de tokens a través de AuthService
class BetterAuthDatasourceImpl implements BetterAuthDatasource {
  final AuthService _authService;

  /// Constructor que recibe la instancia de AuthService.
  /// AuthService debe estar inicializado antes de usar este datasource.
  BetterAuthDatasourceImpl(this._authService);

  // ============================================================
  // AUTENTICACIÓN BÁSICA
  // ============================================================

  /// Inicia sesión con email y contraseña.
  ///
  /// Llama a POST /api/auth/sign-in/email
  /// El token se guarda automáticamente en AuthService.
  ///
  /// Retorna [SignInResponse] con token y usuario.
  /// Lanza [AuthException] si hay error.
  @override
  Future<SignInResponse> signInWithEmail({
    required String email,
    required String password,
    bool? rememberMe,
  }) async {
    try {
      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (response.statusCode == 200 && response.data != null) {
        return SignInResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error desconocido en sign-in: $e');
    }
  }

  /// Registra un nuevo usuario con email y contraseña.
  ///
  /// Llama a POST /api/auth/sign-up/email
  /// El token se guarda automáticamente en AuthService si viene en la respuesta.
  ///
  /// Retorna [SignUpResponse] con usuario (token puede ser null).
  /// Lanza [AuthException] si hay error.
  @override
  Future<SignUpResponse> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String? image,
    bool? rememberMe,
  }) async {
    try {
      final response = await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
        image: image,
        rememberMe: rememberMe,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SignUpResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error desconocido en sign-up: $e');
    }
  }

  /// Cierra la sesión actual del usuario.
  ///
  /// Llama a POST /api/auth/sign-out
  /// Limpia tokens y cookies automáticamente en AuthService.
  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Obtiene la sesión actual del usuario.
  ///
  /// Llama a GET /api/auth/get-session
  /// Retorna null si no hay sesión activa (401).
  ///
  /// Retorna [GetSessionResponse] con sesión y usuario.
  @override
  Future<GetSessionResponse?> getSession() async {
    try {
      final response = await _authService.getSession();

      if (response.statusCode == 200 && response.data != null) {
        return GetSessionResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return null;
    } on DioException catch (e) {
      // 401 significa que no hay sesión activa
      if (e.response?.statusCode == 401) {
        return null;
      }
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // VERIFICACIÓN DE EMAIL
  // ============================================================

  /// Verifica el email del usuario con un token.
  ///
  /// Llama a GET /api/auth/verify-email?token=
  ///
  /// Retorna [VerifyEmailResponse] con usuario y status.
  @override
  Future<VerifyEmailResponse> verifyEmail({required String token}) async {
    try {
      final response = await _authService.verifyEmail(token: token);

      if (response.statusCode == 200 && response.data != null) {
        return VerifyEmailResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Envía un email de verificación al usuario.
  ///
  /// Llama a POST /api/auth/send-verification-email
  ///
  /// Retorna [StatusResponse] con el resultado.
  @override
  Future<StatusResponse> sendVerificationEmail({required String email}) async {
    try {
      final response = await _authService.sendVerificationEmail(email: email);

      if (response.statusCode == 200) {
        return StatusResponse.fromJson(
          response.data as Map<String, dynamic>? ?? {'status': true},
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // GESTIÓN DE CONTRASEÑA
  // ============================================================

  /// Solicita un email para restablecer la contraseña.
  ///
  /// Llama a POST /api/auth/request-password-reset
  ///
  /// Retorna [StatusResponse] con el resultado.
  @override
  Future<StatusResponse> requestPasswordReset({required String email}) async {
    try {
      final response = await _authService.requestPasswordReset(email: email);

      if (response.statusCode == 200) {
        return StatusResponse.fromJson(
          response.data as Map<String, dynamic>? ?? {'status': true},
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Restablece la contraseña usando un token.
  ///
  /// Llama a POST /api/auth/reset-password
  ///
  /// Retorna [StatusResponse] con el resultado.
  @override
  Future<StatusResponse> resetPassword({
    required String newPassword,
    required String token,
  }) async {
    try {
      final response = await _authService.resetPassword(
        newPassword: newPassword,
        token: token,
      );

      if (response.statusCode == 200) {
        return StatusResponse.fromJson(
          response.data as Map<String, dynamic>? ?? {'status': true},
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Cambia la contraseña del usuario autenticado.
  ///
  /// Llama a POST /api/auth/change-password
  ///
  /// Retorna [ChangePasswordResponse] con token opcional y usuario.
  @override
  Future<ChangePasswordResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    bool? revokeOtherSessions,
  }) async {
    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        revokeOtherSessions: revokeOtherSessions,
      );

      if (response.statusCode == 200 && response.data != null) {
        return ChangePasswordResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // GESTIÓN DE PERFIL
  // ============================================================

  /// Actualiza el perfil del usuario (nombre e imagen).
  ///
  /// Llama a POST /api/auth/update-user
  ///
  /// Retorna [BetterAuthUserModel] con el usuario actualizado.
  @override
  Future<BetterAuthUserModel> updateUser({
    String? name,
    String? image,
  }) async {
    try {
      final response = await _authService.updateUser(
        name: name,
        image: image,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        // La respuesta puede ser { user: {...} } o directamente el usuario
        if (data.containsKey('user')) {
          return BetterAuthUserModel.fromJson(
            data['user'] as Map<String, dynamic>,
          );
        }
        return BetterAuthUserModel.fromJson(data);
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error desconocido actualizando perfil: $e');
    }
  }

  /// Cambia el email del usuario autenticado.
  ///
  /// Llama a POST /api/auth/change-email
  ///
  /// Retorna [ChangeEmailResponse] con usuario y status.
  @override
  Future<ChangeEmailResponse> changeEmail({required String newEmail}) async {
    try {
      final response = await _authService.changeEmail(newEmail: newEmail);

      if (response.statusCode == 200 && response.data != null) {
        return ChangeEmailResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Obtiene información detallada de la cuenta.
  ///
  /// Llama a GET /api/auth/account-info
  ///
  /// Retorna [AccountInfoResponse] con usuario y datos adicionales.
  @override
  Future<AccountInfoResponse> getAccountInfo() async {
    try {
      final response = await _authService.accountInfo();

      if (response.statusCode == 200 && response.data != null) {
        return AccountInfoResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Elimina la cuenta del usuario.
  ///
  /// Llama a POST /api/auth/delete-user
  /// Limpia tokens y cookies automáticamente si es exitoso.
  ///
  /// Retorna [StatusResponse] con el resultado.
  @override
  Future<StatusResponse> deleteUser({String? password}) async {
    try {
      final response = await _authService.deleteUser(password: password);

      if (response.statusCode == 200) {
        return StatusResponse.fromJson(
          response.data as Map<String, dynamic>? ?? {'status': true},
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // GESTIÓN DE SESIONES
  // ============================================================

  /// Lista todas las sesiones activas del usuario.
  ///
  /// Llama a GET /api/auth/list-sessions
  ///
  /// Retorna lista de [SessionModel].
  @override
  Future<List<SessionModel>> listSessions() async {
    try {
      final response = await _authService.listSessions();

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> sessionsJson = response.data as List<dynamic>;
        return sessionsJson
            .map((json) => SessionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Revoca una sesión específica por su token.
  ///
  /// Llama a POST /api/auth/revoke-session
  ///
  /// Retorna [StatusResponse] con el resultado.
  @override
  Future<StatusResponse> revokeSession({required String token}) async {
    try {
      final response = await _authService.revokeSession(token: token);

      if (response.statusCode == 200) {
        return StatusResponse.fromJson(
          response.data as Map<String, dynamic>? ?? {'status': true},
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Revoca TODAS las sesiones del usuario (incluyendo la actual).
  ///
  /// Llama a POST /api/auth/revoke-sessions
  /// Limpia tokens y cookies locales.
  ///
  /// Retorna [StatusResponse] con el resultado.
  @override
  Future<StatusResponse> revokeSessions() async {
    try {
      final response = await _authService.revokeSessions();

      if (response.statusCode == 200) {
        return StatusResponse.fromJson(
          response.data as Map<String, dynamic>? ?? {'status': true},
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Revoca todas las sesiones excepto la actual.
  ///
  /// Llama a POST /api/auth/revoke-other-sessions
  /// Útil para "cerrar sesión en otros dispositivos".
  ///
  /// Retorna [StatusResponse] con el resultado.
  @override
  Future<StatusResponse> revokeOtherSessions() async {
    try {
      final response = await _authService.revokeOtherSessions();

      if (response.statusCode == 200) {
        return StatusResponse.fromJson(
          response.data as Map<String, dynamic>? ?? {'status': true},
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // GESTIÓN DE TOKENS
  // ============================================================

  /// Refresca el token de acceso.
  ///
  /// Llama a POST /api/auth/refresh-token
  /// Los nuevos tokens se guardan automáticamente en AuthService.
  ///
  /// Retorna [RefreshTokenResponse] con los nuevos tokens.
  @override
  Future<RefreshTokenResponse> refreshToken({
    String? providerId,
    String? accountId,
    String? userId,
  }) async {
    try {
      final response = await _authService.refreshToken(
        providerId: providerId,
        accountId: accountId,
        userId: userId,
      );

      if (response.statusCode == 200 && response.data != null) {
        return RefreshTokenResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // AUTENTICACIÓN SOCIAL
  // ============================================================

  /// Inicia sesión con un proveedor social.
  ///
  /// Llama a POST /api/auth/sign-in/social
  /// El token se guarda automáticamente en AuthService.
  ///
  /// Retorna [SignInResponse] con token y usuario.
  @override
  Future<SignInResponse> signInSocial({
    required String provider,
    required Map<String, dynamic> idToken,
  }) async {
    try {
      final response = await _authService.signInSocial(
        provider: provider,
        idToken: idToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        return SignInResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Vincula una cuenta social al usuario autenticado.
  ///
  /// Llama a POST /api/auth/link-social
  ///
  /// Retorna [LinkSocialResponse] con url, redirect y status.
  @override
  Future<LinkSocialResponse> linkSocial({
    required String provider,
    Map<String, dynamic>? idToken,
  }) async {
    try {
      final response = await _authService.linkSocial(
        provider: provider,
        idToken: idToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        return LinkSocialResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Lista las cuentas sociales vinculadas.
  ///
  /// Llama a GET /api/auth/list-accounts
  ///
  /// Retorna lista de [LinkedAccountModel].
  @override
  Future<List<LinkedAccountModel>> listAccounts() async {
    try {
      final response = await _authService.listAccounts();

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> accountsJson = response.data as List<dynamic>;
        return accountsJson
            .map((json) =>
                LinkedAccountModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Desvincula una cuenta social.
  ///
  /// Llama a POST /api/auth/unlink-account
  ///
  /// Retorna [StatusResponse] con el resultado.
  @override
  Future<StatusResponse> unlinkAccount({required String providerId}) async {
    try {
      final response = await _authService.unlinkAccount(providerId: providerId);

      if (response.statusCode == 200) {
        return StatusResponse.fromJson(
          response.data as Map<String, dynamic>? ?? {'status': true},
        );
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  /// Verifica que el servicio de auth esté funcionando.
  ///
  /// Llama a GET /api/auth/ok
  ///
  /// Retorna true si el servicio responde correctamente.
  @override
  Future<bool> healthCheck() async {
    try {
      final response = await _authService.healthCheck();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // MANEJO DE ERRORES
  // ============================================================

  /// Convierte una respuesta HTTP con error en una excepción de dominio.
  ///
  /// Analiza el status code y el cuerpo de la respuesta para crear
  /// la excepción apropiada.
  AuthException _handleErrorResponse(Response response) {
    final data = response.data;
    final message = data is Map
        ? (data['message'] ?? data['error'] ?? response.statusMessage)
        : response.statusMessage;

    switch (response.statusCode) {
      case 400:
        return AuthException(
          message?.toString() ?? 'Solicitud inválida',
        );
      case 401:
        return InvalidCredentialsException(
          message?.toString() ?? 'Credenciales inválidas',
        );
      case 403:
        return AuthException(
          message?.toString() ?? 'Acceso denegado',
        );
      case 404:
        return UserNotFoundException(
          message?.toString() ?? 'Usuario no encontrado',
        );
      case 409:
        return EmailAlreadyExistsException(
          message?.toString() ?? 'El email ya está registrado',
        );
      case 422:
        return AuthException(
          message?.toString() ?? 'Datos de entrada inválidos',
        );
      case 429:
        return AuthException(
          message?.toString() ?? 'Demasiadas solicitudes, intenta más tarde',
        );
      default:
        return AuthException(
          message?.toString() ?? 'Error del servidor (${response.statusCode})',
        );
    }
  }

  /// Convierte una excepción de Dio en una excepción de dominio.
  ///
  /// Maneja diferentes tipos de errores de red y conectividad.
  AuthException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return AuthException('Tiempo de conexión agotado');

      case DioExceptionType.sendTimeout:
        return AuthException('Tiempo de envío agotado');

      case DioExceptionType.receiveTimeout:
        return AuthException('Tiempo de respuesta agotado');

      case DioExceptionType.badResponse:
        if (e.response != null) {
          return _handleErrorResponse(e.response!);
        }
        return AuthException('Respuesta inválida del servidor');

      case DioExceptionType.cancel:
        return AuthException('Petición cancelada');

      case DioExceptionType.connectionError:
        return AuthException(
          'Error de conexión. Verifica tu conexión a internet',
        );

      case DioExceptionType.badCertificate:
        return AuthException('Certificado SSL inválido');

      case DioExceptionType.unknown:
        return AuthException('Error desconocido: ${e.message}');
    }
  }
}
