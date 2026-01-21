import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/better_auth_datasource.dart';
import '../models/better_auth_user_model.dart';

/// Implementación del repositorio de autenticación usando Better Auth.
///
/// Esta clase actúa como puente entre el dominio y el datasource,
/// convirtiendo los modelos de datos en entidades de dominio.
///
/// Características:
/// - Convierte respuestas del datasource a entidades de dominio
/// - Mantiene una referencia a la sesión actual en memoria
/// - Gestiona automáticamente el refresh de tokens a través del datasource
/// - El AuthService subyacente maneja la persistencia de tokens
class BetterAuthRepositoryImpl implements AuthRepository {
  final BetterAuthDatasource _datasource;

  /// Sesión actual en memoria para acceso rápido
  AuthSession? _currentSession;

  BetterAuthRepositoryImpl(this._datasource);

  /// Inicia sesión con email y contraseña.
  ///
  /// Llama al datasource y convierte la respuesta en AuthSession.
  /// El token se guarda automáticamente en AuthService.
  @override
  Future<AuthSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await _datasource.signInWithEmail(
      email: email,
      password: password,
      rememberMe: true,
    );

    if (response.user == null) {
      throw Exception('No se recibió información del usuario');
    }

    _currentSession = AuthSession(
      token: response.token ?? '',
      user: response.user!.toEntity(),
      expiresAt: DateTime.now().add(const Duration(days: 7)), // Por defecto 7 días
      refreshToken: null, // Better Auth maneja refresh internamente con cookies
    );

    return _currentSession!;
  }

  /// Registra un nuevo usuario con email y contraseña.
  ///
  /// Después del registro, puede o no devolver un token (depende de la config del backend).
  /// Si no devuelve token, el usuario necesitará hacer login después.
  @override
  Future<AuthSession> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? rut,
    String? birthday,
  }) async {
    final response = await _datasource.signUpWithEmail(
      name: name ?? '',
      email: email,
      password: password,
      rememberMe: true,
    );

    if (response.user == null) {
      throw Exception('No se recibió información del usuario');
    }

    _currentSession = AuthSession(
      token: response.token ?? '',
      user: response.user!.toEntity(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      refreshToken: null,
    );

    return _currentSession!;
  }

  /// Cierra la sesión actual.
  ///
  /// Limpia la sesión local y llama al backend para invalidar la sesión.
  /// AuthService limpia tokens y cookies automáticamente.
  @override
  Future<void> signOut() async {
    await _datasource.signOut();
    _currentSession = null;
  }

  /// Obtiene la sesión actual si existe.
  ///
  /// Primero verifica en memoria, luego consulta al servidor.
  /// Si la sesión ha expirado, intenta refrescarla automáticamente.
  @override
  Future<AuthSession?> getCurrentSession() async {
    try {
      // Consultar al servidor la sesión actual
      final sessionResponse = await _datasource.getSession();

      if (sessionResponse != null) {
        _currentSession = AuthSession(
          token: sessionResponse.session.token,
          user: sessionResponse.user.toEntity(),
          expiresAt: sessionResponse.session.expiresAt,
          refreshToken: null,
        );
        return _currentSession;
      }

      _currentSession = null;
      return null;
    } catch (e) {
      _currentSession = null;
      return null;
    }
  }

  /// Refresca el token de autenticación.
  ///
  /// Nota: Better Auth maneja el refresh automáticamente a través de
  /// cookies y el interceptor en AuthService. Este método es principalmente
  /// para compatibilidad con la interfaz.
  @override
  Future<AuthSession> refreshSession(String refreshToken) async {
    final response = await _datasource.refreshToken();

    if (!response.isSuccess) {
      throw Exception('Error al refrescar el token');
    }

    // Obtener la sesión actualizada
    final sessionResponse = await _datasource.getSession();
    if (sessionResponse == null) {
      throw Exception('No se pudo obtener la sesión después del refresh');
    }

    _currentSession = AuthSession(
      token: sessionResponse.session.token,
      user: sessionResponse.user.toEntity(),
      expiresAt: sessionResponse.session.expiresAt,
      refreshToken: null,
    );

    return _currentSession!;
  }

  /// Envía un email para restablecer la contraseña.
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _datasource.requestPasswordReset(email: email);
  }

  /// Verifica el email del usuario con un token.
  @override
  Future<void> verifyEmail(String token) async {
    await _datasource.verifyEmail(token: token);
  }

  /// Actualiza el perfil del usuario.
  ///
  /// Solo actualiza nombre e imagen ya que son los campos
  /// soportados por el endpoint /api/auth/update-user.
  @override
  Future<AuthUser> updateProfile({
    required String userId,
    String? name,
    String? image,
    String? phone,
    String? rut,
    String? birthday,
    String? address,
    String? bio,
  }) async {
    // El endpoint solo soporta name e image
    final userModel = await _datasource.updateUser(
      name: name,
      image: image,
    );

    final updatedUser = userModel.toEntity();

    // Actualizar el usuario en la sesión actual
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(user: updatedUser);
    }

    return updatedUser;
  }

  /// Cambia la contraseña del usuario autenticado.
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _datasource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Elimina la cuenta del usuario.
  @override
  Future<void> deleteAccount() async {
    await _datasource.deleteUser();
    _currentSession = null;
  }

  /// Verifica si hay una sesión activa.
  @override
  Future<bool> hasActiveSession() async {
    final session = await getCurrentSession();
    return session != null && session.isActive;
  }
}
