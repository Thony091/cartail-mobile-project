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

  // ============================================================
  // ENDPOINT KEYS (para mensajes amigables)
  // ============================================================

  static const String _epSignInEmail = 'sign-in-email';
  static const String _epSignUpEmail = 'sign-up-email';
  static const String _epSignOut = 'sign-out';
  static const String _epGetSession = 'get-session';
  static const String _epVerifyEmail = 'verify-email';
  static const String _epSendVerificationEmail = 'send-verification-email';
  static const String _epRequestPasswordReset = 'request-password-reset';
  static const String _epResetPassword = 'reset-password';
  static const String _epChangePassword = 'change-password';
  static const String _epUpdateUser = 'update-user';
  static const String _epChangeEmail = 'change-email';
  static const String _epAccountInfo = 'account-info';
  static const String _epDeleteUser = 'delete-user';
  static const String _epListSessions = 'list-sessions';
  static const String _epRevokeSession = 'revoke-session';
  static const String _epRevokeSessions = 'revoke-sessions';
  static const String _epRevokeOtherSessions = 'revoke-other-sessions';
  static const String _epRefreshToken = 'refresh-token';
  static const String _epSignInSocial = 'sign-in-social';
  static const String _epLinkSocial = 'link-social';
  static const String _epListAccounts = 'list-accounts';
  static const String _epUnlinkAccount = 'unlink-account';
  static const String _epHealthCheck = 'health-check';

  // ============================================================
  // MENSAJES AMIGABLES POR ENDPOINT/STATUS
  // ============================================================

  static const Map<int, String> _defaultStatusMessages = {
    400: 'Solicitud inválida. Revisa los datos ingresados.',
    401: 'No autorizado. Inicia sesión nuevamente.',
    403: 'No tienes permisos para realizar esta acción.',
    404: 'Recurso no encontrado.',
    422: 'Datos inválidos. Verifica los campos.',
    429: 'Demasiadas solicitudes. Intenta más tarde.',
    500: 'Error del servidor. Intenta más tarde.',
  };

  static const Map<String, Map<int, String>> _endpointErrorMessages = {
    _epSignInEmail: {
      400: 'Datos inválidos. Revisa tu correo y contraseña.',
      401: 'Correo o contraseña incorrectos.',
      403: 'Tu cuenta no tiene permisos para acceder.',
      404: 'No encontramos tu cuenta.',
      429: 'Demasiados intentos. Intenta más tarde.',
      500: 'No pudimos iniciar sesión. Intenta más tarde.',
    },
    _epSignUpEmail: {
      400: 'Datos inválidos. Revisa el formulario.',
      401: 'No autorizado. Intenta nuevamente.',
      403: 'No tienes permisos para registrarte.',
      404: 'Servicio no disponible. Intenta más tarde.',
      422: 'El correo ya está registrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos crear tu cuenta. Intenta más tarde.',
    },
    _epSignInSocial: {
      400: 'No pudimos validar el proveedor social.',
      401: 'Sesión social inválida. Intenta nuevamente.',
      403: 'No tienes permisos para acceder.',
      404: 'Proveedor no disponible.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'Error del servidor. Intenta más tarde.',
    },
    _epGetSession: {
      400: 'Solicitud inválida al verificar sesión.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No autorizado para acceder a la sesión.',
      404: 'Sesión no encontrada.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos verificar tu sesión. Intenta más tarde.',
    },
    _epSignOut: {
      400: 'No pudimos cerrar sesión. Intenta más tarde.',
      401: 'Tu sesión ya no es válida.',
      403: 'No autorizado para cerrar sesión.',
      404: 'Sesión no encontrada.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'Error del servidor al cerrar sesión.',
    },
    _epRequestPasswordReset: {
      400: 'Correo inválido. Revisa e intenta de nuevo.',
      401: 'No autorizado. Intenta nuevamente.',
      403: 'No tienes permisos para recuperar contraseña.',
      404: 'No encontramos un usuario con ese correo.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos enviar el correo. Intenta más tarde.',
    },
    _epResetPassword: {
      400: 'Token inválido o datos incorrectos.',
      401: 'No autorizado para restablecer contraseña.',
      403: 'No tienes permisos para restablecer contraseña.',
      404: 'Token no encontrado o expirado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos restablecer la contraseña.',
    },
    _epVerifyEmail: {
      400: 'Token inválido. Solicita un nuevo enlace.',
      401: 'No autorizado para verificar email.',
      403: 'No tienes permisos para verificar email.',
      404: 'Token no encontrado o expirado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos verificar el email.',
    },
    _epSendVerificationEmail: {
      400: 'Correo inválido. Revisa e intenta de nuevo.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para esta acción.',
      404: 'No encontramos el usuario.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos enviar el correo de verificación.',
    },
    _epChangeEmail: {
      400: 'Correo inválido. Revisa e intenta de nuevo.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para cambiar el correo.',
      404: 'Usuario no encontrado.',
      422: 'El correo ya está en uso.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos cambiar el correo.',
    },
    _epChangePassword: {
      400: 'Contraseña actual inválida o datos incorrectos.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para cambiar contraseña.',
      404: 'Usuario no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos cambiar la contraseña.',
    },
    _epUpdateUser: {
      400: 'Datos inválidos. Revisa el formulario.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para actualizar perfil.',
      404: 'Usuario no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos actualizar tu perfil.',
    },
    _epDeleteUser: {
      400: 'Solicitud inválida para eliminar la cuenta.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para eliminar la cuenta.',
      404: 'Usuario no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos eliminar la cuenta.',
    },
    _epListSessions: {
      400: 'Solicitud inválida al listar sesiones.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para ver sesiones.',
      404: 'Sesiones no encontradas.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos obtener las sesiones.',
    },
    _epRevokeSession: {
      400: 'Solicitud inválida al revocar sesión.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para revocar sesiones.',
      404: 'Sesión no encontrada.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos revocar la sesión.',
    },
    _epRevokeSessions: {
      400: 'Solicitud inválida al revocar sesiones.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para revocar sesiones.',
      404: 'Sesiones no encontradas.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos revocar las sesiones.',
    },
    _epRevokeOtherSessions: {
      400: 'Solicitud inválida al cerrar otras sesiones.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para cerrar otras sesiones.',
      404: 'Sesiones no encontradas.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos cerrar otras sesiones.',
    },
    _epRefreshToken: {
      400: 'Token inválido. Inicia sesión nuevamente.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para refrescar la sesión.',
      404: 'Sesión no encontrada.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos refrescar la sesión.',
    },
    _epLinkSocial: {
      400: 'Datos del proveedor inválidos.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para vincular cuentas.',
      404: 'Proveedor no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos vincular la cuenta.',
    },
    _epListAccounts: {
      400: 'Solicitud inválida al listar cuentas.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para ver cuentas vinculadas.',
      404: 'No se encontraron cuentas vinculadas.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos obtener las cuentas vinculadas.',
    },
    _epUnlinkAccount: {
      400: 'Solicitud inválida al desvincular cuenta.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para desvincular cuentas.',
      404: 'Cuenta no encontrada.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos desvincular la cuenta.',
    },
    _epAccountInfo: {
      400: 'Solicitud inválida al obtener la cuenta.',
      401: 'No autorizado. Inicia sesión nuevamente.',
      403: 'No tienes permisos para ver la cuenta.',
      404: 'Cuenta no encontrada.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos obtener la información de la cuenta.',
    },
    _epHealthCheck: {
      500: 'El servicio de autenticación no está disponible.',
    },
  };

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
        throw _handleErrorResponse(response, endpoint: _epSignInEmail);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epSignInEmail);
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
        throw _handleErrorResponse(response, endpoint: _epSignUpEmail);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epSignUpEmail);
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
      throw _handleDioError(e, endpoint: _epSignOut);
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
      throw _handleDioError(e, endpoint: _epGetSession);
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
        throw _handleErrorResponse(response, endpoint: _epVerifyEmail);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epVerifyEmail);
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
        throw _handleErrorResponse(response, endpoint: _epSendVerificationEmail);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epSendVerificationEmail);
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
        throw _handleErrorResponse(response, endpoint: _epRequestPasswordReset);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epRequestPasswordReset);
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
        throw _handleErrorResponse(response, endpoint: _epResetPassword);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epResetPassword);
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
        throw _handleErrorResponse(response, endpoint: _epChangePassword);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epChangePassword);
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
        throw _handleErrorResponse(response, endpoint: _epUpdateUser);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epUpdateUser);
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
        throw _handleErrorResponse(response, endpoint: _epChangeEmail);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epChangeEmail);
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
        throw _handleErrorResponse(response, endpoint: _epAccountInfo);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epAccountInfo);
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
        throw _handleErrorResponse(response, endpoint: _epDeleteUser);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epDeleteUser);
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
        throw _handleErrorResponse(response, endpoint: _epListSessions);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epListSessions);
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
        throw _handleErrorResponse(response, endpoint: _epRevokeSession);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epRevokeSession);
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
        throw _handleErrorResponse(response, endpoint: _epRevokeSessions);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epRevokeSessions);
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
        throw _handleErrorResponse(response, endpoint: _epRevokeOtherSessions);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epRevokeOtherSessions);
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
        throw _handleErrorResponse(response, endpoint: _epRefreshToken);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epRefreshToken);
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
        throw _handleErrorResponse(response, endpoint: _epSignInSocial);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epSignInSocial);
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
        throw _handleErrorResponse(response, endpoint: _epLinkSocial);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epLinkSocial);
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
        throw _handleErrorResponse(response, endpoint: _epListAccounts);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epListAccounts);
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
        throw _handleErrorResponse(response, endpoint: _epUnlinkAccount);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epUnlinkAccount);
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
  AuthException _handleErrorResponse(
    Response response, {
    String? endpoint,
  }) {
    final data = response.data;
    final message = data is Map
        ? (data['message'] ?? data['error'] ?? response.statusMessage)
        : response.statusMessage;
    final statusCode = response.statusCode;
    final friendlyMessage =
        _friendlyMessage(endpoint: endpoint, statusCode: statusCode);

    switch (statusCode) {
      case 400:
        return AuthException(
          friendlyMessage ?? message?.toString() ?? 'Solicitud inválida',
        );
      case 401:
        return InvalidCredentialsException(
          friendlyMessage ?? message?.toString() ?? 'Credenciales inválidas',
        );
      case 403:
        return AuthException(
          friendlyMessage ?? message?.toString() ?? 'Acceso denegado',
        );
      case 404:
        return UserNotFoundException(
          friendlyMessage ?? message?.toString() ?? 'Usuario no encontrado',
        );
      case 409:
        return EmailAlreadyExistsException(
          friendlyMessage ?? message?.toString() ?? 'El email ya está registrado',
        );
      case 422:
        return AuthException(
          friendlyMessage ?? message?.toString() ?? 'Datos de entrada inválidos',
        );
      case 429:
        return AuthException(
          friendlyMessage ??
              message?.toString() ??
              'Demasiadas solicitudes, intenta más tarde',
        );
      default:
        return AuthException(
          friendlyMessage ??
              message?.toString() ??
              'Error del servidor ($statusCode)',
        );
    }
  }

  /// Convierte una excepción de Dio en una excepción de dominio.
  ///
  /// Maneja diferentes tipos de errores de red y conectividad.
  AuthException _handleDioError(
    DioException e, {
    String? endpoint,
  }) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return AuthException('Tiempo de conexión agotado');

      case DioExceptionType.sendTimeout:
        return AuthException('Tiempo de envío agotado');

      case DioExceptionType.receiveTimeout:
        return AuthException('Tiempo de respuesta agotado');

      case DioExceptionType.badResponse:
        if (e.response != null) {
          return _handleErrorResponse(e.response!, endpoint: endpoint);
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

  String? _friendlyMessage({
    String? endpoint,
    int? statusCode,
  }) {
    if (statusCode == null) return null;
    final endpointMessages = _endpointErrorMessages[endpoint];
    return endpointMessages?[statusCode] ?? _defaultStatusMessages[statusCode];
  }
}
