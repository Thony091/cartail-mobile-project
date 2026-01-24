import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../user/domain/entities/user_role.dart';
import '../../data/datasources/better_auth_datasource.dart';
import '../../data/datasources/better_auth_datasource_impl.dart';
import '../../data/repositories/better_auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../../../config/services/auth_service.dart';
import '../../domain/repositories/auth_repository.dart';

// ============================================================
// PROVIDERS DE INFRAESTRUCTURA
// ============================================================

/// Provider para el datasource de Better Auth.
///
/// Usa AuthService internamente para comunicación con la API.
/// AuthService maneja automáticamente:
/// - Almacenamiento seguro de tokens (FlutterSecureStorage)
/// - Gestión de cookies (CookieJar)
/// - Refresh automático de tokens expirados
final betterAuthDatasourceProvider = Provider<BetterAuthDatasource>((ref) {
  final authService = ref.watch(authServiceProvider);
  return BetterAuthDatasourceImpl(authService);
});

/// Provider para el repositorio de autenticación con Better Auth.
///
/// Convierte las respuestas del datasource en entidades de dominio.
final betterAuthRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(betterAuthDatasourceProvider);
  return BetterAuthRepositoryImpl(datasource);
});

// ============================================================
// ESTADO DE AUTENTICACIÓN
// ============================================================

/// Estado de autenticación para Better Auth.
///
/// Contiene información sobre:
/// - Status actual (loading, authenticated, unauthenticated, error)
/// - Sesión del usuario (token, datos del usuario, expiración)
/// - Mensaje de error si aplica
class BetterAuthState {
  final BetterAuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  const BetterAuthState({
    this.status = BetterAuthStatus.initial,
    this.session,
    this.errorMessage,
  });

  /// Obtiene el usuario actual (null si no está autenticado)
  AuthUser? get user => session?.user;

  /// Obtiene el token actual (null si no está autenticado)
  String? get token => session?.token;

  /// Verifica si el usuario está autenticado
  bool get isAuthenticated =>
      status == BetterAuthStatus.authenticated && session != null;

  /// Verifica si está cargando
  bool get isLoading => status == BetterAuthStatus.loading;

  /// Verifica si hubo un error
  bool get hasError => status == BetterAuthStatus.error;

  /// Obtiene el rol del usuario
  UserRole get userRole => user?.role ?? UserRole.guest;

  /// Verifica si el usuario es invitado
  bool get isGuest => userRole == UserRole.guest;

  /// Verifica si el usuario es usuario regular
  bool get isUser => userRole == UserRole.user;

  /// Verifica si el usuario es operario
  bool get isOperator => userRole == UserRole.operator;

  /// Verifica si el usuario es administrador
  bool get isAdmin => userRole == UserRole.admin;

  /// Crea una copia del estado con los valores actualizados
  BetterAuthState copyWith({
    BetterAuthStatus? status,
    AuthSession? session,
    String? errorMessage,
  }) {
    return BetterAuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Crea un estado limpio (sin sesión)
  BetterAuthState cleared() {
    return const BetterAuthState(
      status: BetterAuthStatus.unauthenticated,
      session: null,
      errorMessage: null,
    );
  }

  @override
  String toString() {
    return 'BetterAuthState(status: $status, user: ${user?.email}, error: $errorMessage)';
  }
}

/// Estados posibles de la autenticación
enum BetterAuthStatus {
  /// Estado inicial, verificando sesión existente
  initial,

  /// Cargando (login, registro, etc.)
  loading,

  /// Usuario autenticado correctamente
  authenticated,

  /// Usuario no autenticado
  unauthenticated,

  /// Error durante la operación
  error,
}

// ============================================================
// NOTIFIER DE AUTENTICACIÓN
// ============================================================

/// Notifier para manejar el estado de autenticación con Better Auth.
///
/// Proporciona métodos para:
/// - signIn: Iniciar sesión con email/password
/// - signUp: Registrar nuevo usuario
/// - signOut: Cerrar sesión
/// - updateProfile: Actualizar datos del usuario
/// - changePassword: Cambiar contraseña
/// - deleteAccount: Eliminar cuenta
/// - sendPasswordResetEmail: Enviar email de recuperación
///
/// La gestión de tokens es automática a través de AuthService:
/// - Los tokens se almacenan en FlutterSecureStorage
/// - El refresh de tokens expirados es automático
/// - Las cookies de sesión se persisten con CookieJar
class BetterAuthNotifier extends StateNotifier<BetterAuthState> {
  final AuthRepository _repository;
  final AuthService _authService;
  int _sessionRetryCount = 0;
  bool _isChecking = false;
  static const int _maxSessionRetries = 3;

  BetterAuthNotifier({
    required AuthRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService,
        super(const BetterAuthState()) {
    // Verificar estado de autenticación al iniciar
    _checkAuthStatus();
  }

  /// Verifica el estado de autenticación al iniciar.
  ///
  /// Consulta al servidor si hay una sesión activa basándose en
  /// los tokens almacenados en AuthService.
  Future<void> _checkAuthStatus() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      state = state.copyWith(status: BetterAuthStatus.loading);

      // Inicializar AuthService si no está inicializado
      await _authService.init();

      // Consultar al servidor la sesión actual (token o cookie)
      final session = await _repository.getCurrentSession();
      if (session != null) {
        _sessionRetryCount = 0;
        state = state.copyWith(
          status: BetterAuthStatus.authenticated,
          session: session,
        );
      } else {
        // No hay sesión válida en el servidor
        _sessionRetryCount = 0;
        state = state.copyWith(
          status: BetterAuthStatus.unauthenticated,
          session: null,
        );
      }
    } catch (e) {
      debugPrint('Error verificando estado de autenticación: $e');
      if (_authService.hasActiveSession) {
        _sessionRetryCount += 1;
        if (_sessionRetryCount <= _maxSessionRetries) {
          final delaySeconds = (_sessionRetryCount * 2).clamp(2, 10);
          state = state.copyWith(status: BetterAuthStatus.loading);
          Future<void>.delayed(Duration(seconds: delaySeconds), _checkAuthStatus);
        } else {
          _sessionRetryCount = 0;
          state = state.copyWith(
            status: BetterAuthStatus.error,
            errorMessage:
                'No se pudo restaurar la sesión. Intenta nuevamente.',
            session: null,
          );
        }
      } else {
        _sessionRetryCount = 0;
        state = state.copyWith(
          status: BetterAuthStatus.unauthenticated,
          session: null,
        );
      }
    } finally {
      _isChecking = false;
    }
  }

  /// Inicia sesión con email y contraseña.
  ///
  /// Los tokens se guardan automáticamente en AuthService.
  /// Lanza excepción si hay error.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(
        status: BetterAuthStatus.loading,
        errorMessage: null,
      );

      final session = await _repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        status: BetterAuthStatus.authenticated,
        session: session,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: BetterAuthStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Registra un nuevo usuario con email y contraseña.
  ///
  /// Los tokens se guardan automáticamente si el backend los retorna.
  /// Lanza excepción si hay error.
  Future<void> signUp({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? rut,
    String? birthday,
  }) async {
    try {
      state = state.copyWith(
        status: BetterAuthStatus.loading,
        errorMessage: null,
      );

      final session = await _repository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
        rut: rut,
        birthday: birthday,
      );

      state = state.copyWith(
        status: BetterAuthStatus.authenticated,
        session: session,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: BetterAuthStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Cierra la sesión actual.
  ///
  /// Limpia tokens en AuthService y cookies automáticamente.
  Future<void> signOut() async {
    try {
      await _repository.signOut();
      state = state.cleared();
    } catch (e) {
      debugPrint('Error cerrando sesión: $e');
      // Limpiar estado de todas formas
      state = state.cleared();
    }
  }

  /// Envía un email para restablecer la contraseña.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
    } catch (e) {
      state = state.copyWith(
        status: BetterAuthStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Actualiza el perfil del usuario.
  ///
  /// Solo actualiza nombre e imagen (campos soportados por la API).
  Future<void> updateProfile({
    String? name,
    String? image,
    String? phone,
    String? rut,
    String? birthday,
    String? address,
    String? bio,
  }) async {
    if (state.user == null) {
      throw Exception('No hay usuario autenticado');
    }

    try {
      final updatedUser = await _repository.updateProfile(
        userId: state.user!.id,
        name: name,
        image: image,
        phone: phone,
        rut: rut,
        birthday: birthday,
        address: address,
        bio: bio,
      );

      state = state.copyWith(
        session: state.session?.copyWith(user: updatedUser),
      );
    } catch (e) {
      state = state.copyWith(
        status: BetterAuthStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Cambia la contraseña del usuario autenticado.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      state = state.copyWith(
        status: BetterAuthStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Elimina la cuenta del usuario.
  ///
  /// Después de eliminar, cierra la sesión automáticamente.
  Future<void> deleteAccount() async {
    try {
      await _repository.deleteAccount();
      state = state.cleared();
    } catch (e) {
      state = state.copyWith(
        status: BetterAuthStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Refresca el estado de autenticación.
  ///
  /// Útil para verificar si la sesión sigue activa después de
  /// que la app vuelve del background.
  Future<void> refreshAuthState() async {
    await _checkAuthStatus();
  }

  /// Limpia el mensaje de error actual.
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(
        status: state.session != null
            ? BetterAuthStatus.authenticated
            : BetterAuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }
}

// ============================================================
// PROVIDER PRINCIPAL
// ============================================================

/// Provider principal para la autenticación con Better Auth.
///
/// Uso:
/// ```dart
/// // Leer estado
/// final authState = ref.watch(betterAuthProvider);
///
/// // Verificar autenticación
/// if (authState.isAuthenticated) {
///   print('Usuario: ${authState.user?.email}');
/// }
///
/// // Ejecutar acciones
/// await ref.read(betterAuthProvider.notifier).signIn(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// ```
final betterAuthProvider =
    StateNotifierProvider<BetterAuthNotifier, BetterAuthState>((ref) {
  final repository = ref.watch(betterAuthRepositoryProvider);
  final authService = ref.watch(authServiceProvider);

  return BetterAuthNotifier(
    repository: repository,
    authService: authService,
  );
});

// ============================================================
// PROVIDERS DERIVADOS (CONVENIENCIA)
// ============================================================

/// Provider que indica si el usuario está autenticado.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(betterAuthProvider).isAuthenticated;
});

/// Provider que indica si está cargando.
final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(betterAuthProvider).isLoading;
});

/// Provider que retorna el usuario actual o null.
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(betterAuthProvider).user;
});

/// Provider que retorna el rol del usuario.
final userRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(betterAuthProvider).userRole;
});

/// Provider que indica si el usuario es admin.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(betterAuthProvider).isAdmin;
});

/// Provider que indica si el usuario es operador.
final isOperatorProvider = Provider<bool>((ref) {
  return ref.watch(betterAuthProvider).isOperator;
});
