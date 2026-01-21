import '../models/better_auth_response_models.dart';
import '../models/better_auth_user_model.dart';

/// Interfaz para el datasource de Better Auth.
/// Define todos los métodos disponibles para autenticación.
abstract class BetterAuthDatasource {
  // ============================================================
  // AUTENTICACIÓN BÁSICA
  // ============================================================

  /// Inicia sesión con email y contraseña.
  /// Retorna la respuesta de sign-in con token y usuario.
  Future<SignInResponse> signInWithEmail({
    required String email,
    required String password,
    bool? rememberMe,
  });

  /// Registra un nuevo usuario con email y contraseña.
  /// Retorna la respuesta de sign-up con usuario (token puede ser null).
  Future<SignUpResponse> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String? image,
    bool? rememberMe,
  });

  /// Cierra la sesión actual del usuario.
  Future<void> signOut();

  /// Obtiene la sesión actual del usuario.
  /// Retorna null si no hay sesión activa.
  Future<GetSessionResponse?> getSession();

  // ============================================================
  // VERIFICACIÓN DE EMAIL
  // ============================================================

  /// Verifica el email del usuario con un token.
  /// Retorna el usuario actualizado y el status.
  Future<VerifyEmailResponse> verifyEmail({required String token});

  /// Envía un email de verificación al usuario.
  Future<StatusResponse> sendVerificationEmail({required String email});

  // ============================================================
  // GESTIÓN DE CONTRASEÑA
  // ============================================================

  /// Solicita un email para restablecer la contraseña.
  Future<StatusResponse> requestPasswordReset({required String email});

  /// Restablece la contraseña usando un token.
  Future<StatusResponse> resetPassword({
    required String newPassword,
    required String token,
  });

  /// Cambia la contraseña del usuario autenticado.
  /// Retorna el usuario actualizado.
  Future<ChangePasswordResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    bool? revokeOtherSessions,
  });

  // ============================================================
  // GESTIÓN DE PERFIL
  // ============================================================

  /// Actualiza el perfil del usuario (nombre e imagen).
  /// Retorna el usuario actualizado.
  Future<BetterAuthUserModel> updateUser({
    String? name,
    String? image,
  });

  /// Cambia el email del usuario autenticado.
  /// Retorna el usuario actualizado y el status.
  Future<ChangeEmailResponse> changeEmail({required String newEmail});

  /// Obtiene información detallada de la cuenta.
  Future<AccountInfoResponse> getAccountInfo();

  /// Elimina la cuenta del usuario.
  Future<StatusResponse> deleteUser({String? password});

  // ============================================================
  // GESTIÓN DE SESIONES
  // ============================================================

  /// Lista todas las sesiones activas del usuario.
  Future<List<SessionModel>> listSessions();

  /// Revoca una sesión específica por su token.
  Future<StatusResponse> revokeSession({required String token});

  /// Revoca TODAS las sesiones del usuario (incluyendo la actual).
  Future<StatusResponse> revokeSessions();

  /// Revoca todas las sesiones excepto la actual.
  Future<StatusResponse> revokeOtherSessions();

  // ============================================================
  // GESTIÓN DE TOKENS
  // ============================================================

  /// Refresca el token de acceso.
  /// Retorna los nuevos tokens.
  Future<RefreshTokenResponse> refreshToken({
    String? providerId,
    String? accountId,
    String? userId,
  });

  // ============================================================
  // AUTENTICACIÓN SOCIAL
  // ============================================================

  /// Inicia sesión con un proveedor social.
  Future<SignInResponse> signInSocial({
    required String provider,
    required Map<String, dynamic> idToken,
  });

  /// Vincula una cuenta social al usuario autenticado.
  Future<LinkSocialResponse> linkSocial({
    required String provider,
    Map<String, dynamic>? idToken,
  });

  /// Lista las cuentas sociales vinculadas.
  Future<List<LinkedAccountModel>> listAccounts();

  /// Desvincula una cuenta social.
  Future<StatusResponse> unlinkAccount({required String providerId});

  // ============================================================
  // UTILIDADES
  // ============================================================

  /// Verifica que el servicio de auth esté funcionando.
  Future<bool> healthCheck();
}
