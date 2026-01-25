import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/services/auth_service.dart';
import '../../data/datasources/admin_auth_datasource.dart';
import '../../data/datasources/admin_auth_datasource_impl.dart';
import '../../data/models/admin_response_models.dart';
import '../../data/models/better_auth_response_models.dart';

// ============================================================
// PROVIDERS DE INFRAESTRUCTURA
// ============================================================

/// Provider para el datasource de administración.
///
/// Usa AuthService internamente para comunicación con la API.
/// Requiere que el usuario actual tenga rol de admin.
final adminAuthDatasourceProvider = Provider<AdminAuthDatasource>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AdminAuthDatasourceImpl(authService);
});

// ============================================================
// ESTADOS
// ============================================================

/// Estado para operaciones admin que retornan un solo usuario.
class AdminUserState {
  final bool isLoading;
  final AdminUserModel? user;
  final String? errorMessage;

  const AdminUserState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AdminUserState copyWith({
    bool? isLoading,
    AdminUserModel? user,
    String? errorMessage,
  }) {
    return AdminUserState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  AdminUserState cleared() {
    return const AdminUserState(
      isLoading: false,
      user: null,
      errorMessage: null,
    );
  }
}

/// Estado para lista de usuarios con paginación.
class AdminUsersListState {
  final bool isLoading;
  final List<AdminUserModel> users;
  final int total;
  final int limit;
  final int offset;
  final String? errorMessage;

  const AdminUsersListState({
    this.isLoading = false,
    this.users = const [],
    this.total = 0,
    this.limit = 10,
    this.offset = 0,
    this.errorMessage,
  });

  /// Calcula el número total de páginas.
  int get totalPages => (total / limit).ceil();

  /// Calcula la página actual (basado en 0).
  int get currentPage => (offset / limit).floor();

  /// Verifica si hay más páginas.
  bool get hasMore => offset + users.length < total;

  /// Verifica si está en la primera página.
  bool get isFirstPage => offset == 0;

  AdminUsersListState copyWith({
    bool? isLoading,
    List<AdminUserModel>? users,
    int? total,
    int? limit,
    int? offset,
    String? errorMessage,
  }) {
    return AdminUsersListState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  AdminUsersListState cleared() {
    return const AdminUsersListState(
      isLoading: false,
      users: [],
      total: 0,
      limit: 10,
      offset: 0,
      errorMessage: null,
    );
  }
}

/// Estado para lista de sesiones de usuario.
class AdminUserSessionsState {
  final bool isLoading;
  final List<SessionModel> sessions;
  final String? errorMessage;

  const AdminUserSessionsState({
    this.isLoading = false,
    this.sessions = const [],
    this.errorMessage,
  });

  AdminUserSessionsState copyWith({
    bool? isLoading,
    List<SessionModel>? sessions,
    String? errorMessage,
  }) {
    return AdminUserSessionsState(
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Estado para impersonación de usuario.
class AdminImpersonationState {
  final bool isImpersonating;
  final AdminUserModel? impersonatedUser;
  final String? errorMessage;

  const AdminImpersonationState({
    this.isImpersonating = false,
    this.impersonatedUser,
    this.errorMessage,
  });

  AdminImpersonationState copyWith({
    bool? isImpersonating,
    AdminUserModel? impersonatedUser,
    String? errorMessage,
  }) {
    return AdminImpersonationState(
      isImpersonating: isImpersonating ?? this.isImpersonating,
      impersonatedUser: impersonatedUser ?? this.impersonatedUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  AdminImpersonationState cleared() {
    return const AdminImpersonationState(
      isImpersonating: false,
      impersonatedUser: null,
      errorMessage: null,
    );
  }
}

// ============================================================
// NOTIFIERS
// ============================================================

/// Notifier para gestión de lista de usuarios.
///
/// Proporciona métodos para:
/// - loadUsers: Cargar lista de usuarios con paginación
/// - nextPage: Cargar siguiente página
/// - previousPage: Cargar página anterior
/// - refresh: Recargar lista actual
class AdminUsersListNotifier extends StateNotifier<AdminUsersListState> {
  final AdminAuthDatasource _datasource;

  AdminUsersListNotifier(this._datasource) : super(const AdminUsersListState()){
    loadUsers();
  }

  /// Carga usuarios con filtros opcionales.
  Future<void> loadUsers({
    String? searchValue,
    int? limit,
    int? offset,
    String? sortBy,
    String? sortDirection,
    String? filterField,
    String? filterOperator,
    String? filterValue,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true, 
        errorMessage: null
      );

      final response = await _datasource.listUsers(
        searchValue: searchValue,
        limit: limit ?? state.limit,
        offset: offset ?? 0,
        sortBy: sortBy,
        sortDirection: sortDirection,
        filterField: filterField,
        filterOperator: filterOperator,
        filterValue: filterValue,
      );

      state = state.copyWith(
        isLoading: false,
        users: response.users,
        total: response.total,
        limit: response.limit,
        offset: response.offset,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Carga la siguiente página de usuarios.
  Future<void> nextPage() async {
    if (!state.hasMore || state.isLoading) return;
    await loadUsers(offset: state.offset + state.limit);
  }

  /// Carga la página anterior de usuarios.
  Future<void> previousPage() async {
    if (state.isFirstPage || state.isLoading) return;
    await loadUsers(offset: state.offset - state.limit);
  }

  /// Recarga la lista actual.
  Future<void> refresh() async {
    await loadUsers(offset: state.offset);
  }

  /// Limpia la lista.
  void clear() {
    state = state.cleared();
  }
}

/// Notifier para gestión de un usuario individual (CRUD).
///
/// Proporciona métodos para:
/// - getUser: Obtener usuario por ID
/// - createUser: Crear nuevo usuario
/// - updateUser: Actualizar usuario existente
/// - setRole: Asignar rol a usuario
/// - setPassword: Establecer nueva contraseña
/// - banUser: Banear usuario
/// - unbanUser: Quitar baneo
class AdminUserNotifier extends StateNotifier<AdminUserState> {
  final AdminAuthDatasource _datasource;

  AdminUserNotifier(this._datasource) : super(const AdminUserState());

  /// Obtiene un usuario por su ID.
  Future<void> getUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final response = await _datasource.getUser(userId: userId);
      state = state.copyWith(isLoading: false, user: response.user);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Crea un nuevo usuario.
  Future<AdminUserModel?> createUser({
    required String email,
    required String password,
    required String name,
    String? role,
    Map<String, dynamic>? data,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final response = await _datasource.createUser(
        email: email,
        password: password,
        name: name,
        role: role,
        data: data,
      );
      state = state.copyWith(isLoading: false, user: response.user);
      return response.user;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  /// Actualiza un usuario existente.
  Future<AdminUserModel?> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final response = await _datasource.updateUser(userId: userId, data: data);
      state = state.copyWith(isLoading: false, user: response.user);
      return response.user;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  /// Asigna un rol a un usuario.
  Future<bool> setRole({
    required String userId,
    required String role,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final response = await _datasource.setRole(userId: userId, role: role);
      state = state.copyWith(isLoading: false, user: response.user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Establece nueva contraseña para un usuario.
  Future<bool> setPassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final response = await _datasource.setUserPassword(
        userId: userId,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      return response.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Banea a un usuario.
  Future<bool> banUser({
    required String userId,
    String? reason,
    int? expiresIn,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final response = await _datasource.banUser(
        userId: userId,
        banReason: reason,
        banExpiresIn: expiresIn,
      );
      state = state.copyWith(isLoading: false, user: response.user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Quita el baneo de un usuario.
  Future<bool> unbanUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final response = await _datasource.unbanUser(userId: userId);
      state = state.copyWith(isLoading: false, user: response.user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Limpia el estado.
  void clear() {
    state = state.cleared();
  }
}

/// Notifier para gestión de sesiones de usuario.
class AdminUserSessionsNotifier extends StateNotifier<AdminUserSessionsState> {
  final AdminAuthDatasource _datasource;

  AdminUserSessionsNotifier(this._datasource)
      : super(const AdminUserSessionsState());

  /// Lista las sesiones de un usuario.
  Future<void> listSessions(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final response = await _datasource.listUserSessions(userId: userId);
      state = state.copyWith(isLoading: false, sessions: response.sessions);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Revoca una sesión específica.
  Future<bool> revokeSession(String sessionToken) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final response =
          await _datasource.revokeUserSession(sessionToken: sessionToken);
      if (response.success) {
        // Remover sesión de la lista local
        final updatedSessions = state.sessions
            .where((s) => s.token != sessionToken)
            .toList();
        state = state.copyWith(isLoading: false, sessions: updatedSessions);
      }
      return response.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Revoca todas las sesiones de un usuario.
  Future<bool> revokeAllSessions(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final response = await _datasource.revokeUserSessions(userId: userId);
      if (response.success) {
        state = state.copyWith(isLoading: false, sessions: []);
      }
      return response.success;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

/// Notifier para impersonación de usuarios.
class AdminImpersonationNotifier extends StateNotifier<AdminImpersonationState> {
  final AdminAuthDatasource _datasource;

  AdminImpersonationNotifier(this._datasource)
      : super(const AdminImpersonationState());

  /// Inicia impersonación de un usuario.
  ///
  /// El token de impersonación se guarda automáticamente en AuthService.
  Future<bool> startImpersonation(String userId) async {
    try {
      state = state.copyWith(isImpersonating: false, errorMessage: null);
      final response = await _datasource.impersonateUser(userId: userId);
      state = AdminImpersonationState(
        isImpersonating: true,
        impersonatedUser: response.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Termina la impersonación actual.
  Future<bool> stopImpersonation() async {
    if (!state.isImpersonating) return true;

    try {
      await _datasource.stopImpersonating();
      state = state.cleared();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

// ============================================================
// PROVIDERS PRINCIPALES
// ============================================================

/// Provider para lista de usuarios con paginación.
final adminUsersListProvider =
    StateNotifierProvider<AdminUsersListNotifier, AdminUsersListState>((ref) {
  final datasource = ref.watch(adminAuthDatasourceProvider);
  return AdminUsersListNotifier(datasource);
});

/// Provider para gestión de un usuario individual.
final adminUserProvider =
    StateNotifierProvider<AdminUserNotifier, AdminUserState>((ref) {
  final datasource = ref.watch(adminAuthDatasourceProvider);
  return AdminUserNotifier(datasource);
});

/// Provider para gestión de sesiones de usuario.
final adminUserSessionsProvider =
    StateNotifierProvider<AdminUserSessionsNotifier, AdminUserSessionsState>(
        (ref) {
  final datasource = ref.watch(adminAuthDatasourceProvider);
  return AdminUserSessionsNotifier(datasource);
});

/// Provider para impersonación de usuarios.
final adminImpersonationProvider =
    StateNotifierProvider<AdminImpersonationNotifier, AdminImpersonationState>(
        (ref) {
  final datasource = ref.watch(adminAuthDatasourceProvider);
  return AdminImpersonationNotifier(datasource);
});

// ============================================================
// PROVIDERS DE CONVENIENCIA
// ============================================================

/// Provider que indica si hay una impersonación activa.
final isImpersonatingProvider = Provider<bool>((ref) {
  return ref.watch(adminImpersonationProvider).isImpersonating;
});

/// Provider que retorna el usuario impersonado actual.
final impersonatedUserProvider = Provider<AdminUserModel?>((ref) {
  return ref.watch(adminImpersonationProvider).impersonatedUser;
});

/// Provider para verificar permisos admin.
///
/// Uso:
/// ```dart
/// final hasPermission = await ref.read(adminPermissionProvider({
///   'resource': 'users',
///   'action': 'delete',
/// }).future);
/// ```
final adminPermissionProvider =
    FutureProvider.family<bool, Map<String, dynamic>>((ref, permissions) async {
  final datasource = ref.watch(adminAuthDatasourceProvider);
  try {
    final response = await datasource.hasPermission(permissions: permissions);
    return response.hasPermission;
  } catch (e) {
    return false;
  }
});
