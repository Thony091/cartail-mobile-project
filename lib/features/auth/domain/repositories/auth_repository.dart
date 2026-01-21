import '../entities/auth_session.dart';
import '../entities/auth_user.dart';

/// Repositorio abstracto para autenticación
/// Permite cambiar entre diferentes proveedores (Firebase, better_auth, etc.)
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  Future<AuthSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  Future<AuthSession> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? rut,
    String? birthday,
  });

  /// Cierra la sesión actual
  Future<void> signOut();

  /// Obtiene la sesión actual si existe
  Future<AuthSession?> getCurrentSession();

  /// Refresca el token de autenticación
  Future<AuthSession> refreshSession(String refreshToken);

  /// Envía un email para restablecer la contraseña
  Future<void> sendPasswordResetEmail(String email);

  /// Verifica el email del usuario
  Future<void> verifyEmail(String token);

  /// Actualiza el perfil del usuario
  Future<AuthUser> updateProfile({
    required String userId,
    String? name,
    String? image,
    String? phone,
    String? rut,
    String? birthday,
    String? address,
    String? bio,
  });

  /// Cambia la contraseña del usuario
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Elimina la cuenta del usuario
  Future<void> deleteAccount();

  /// Verifica si hay una sesión activa
  Future<bool> hasActiveSession();
}
