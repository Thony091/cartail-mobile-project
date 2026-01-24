import 'package:dio/dio.dart';

import '../../../../config/services/auth_service.dart';
import '../../domain/errors/auth_exceptions.dart';
import '../models/admin_response_models.dart';
import 'admin_auth_datasource.dart';

/// Implementación del datasource de administración usando AuthService.
///
/// Todas las operaciones requieren que el usuario actual tenga rol de admin.
/// AuthService maneja automáticamente:
/// - Headers de autenticación
/// - Cookies de sesión
/// - Refresh de tokens
///
/// Las respuestas del servidor se parsean a los modelos correspondientes
/// definidos en admin_response_models.dart.
class AdminAuthDatasourceImpl implements AdminAuthDatasource {
  final AuthService _authService;

  AdminAuthDatasourceImpl(this._authService);

  // ============================================================
  // ENDPOINT KEYS (para mensajes amigables)
  // ============================================================

  static const String _epSetRole = 'admin-set-role';
  static const String _epGetUser = 'admin-get-user';
  static const String _epCreateUser = 'admin-create-user';
  static const String _epUpdateUser = 'admin-update-user';
  static const String _epListUsers = 'admin-list-users';
  static const String _epListUserSessions = 'admin-list-user-sessions';
  static const String _epUnbanUser = 'admin-unban-user';
  static const String _epBanUser = 'admin-ban-user';
  static const String _epImpersonateUser = 'admin-impersonate-user';
  static const String _epStopImpersonating = 'admin-stop-impersonating';
  static const String _epRevokeUserSession = 'admin-revoke-user-session';
  static const String _epRevokeUserSessions = 'admin-revoke-user-sessions';
  static const String _epSetUserPassword = 'admin-set-user-password';
  static const String _epHasPermission = 'admin-has-permission';

  // ============================================================
  // MENSAJES AMIGABLES POR ENDPOINT/STATUS
  // ============================================================

  static const Map<int, String> _defaultStatusMessages = {
    400: 'Solicitud inválida. Revisa los datos ingresados.',
    401: 'No autorizado. Inicia sesión nuevamente.',
    403: 'No tienes permisos para realizar esta acción.',
    404: 'Recurso no encontrado.',
    429: 'Demasiadas solicitudes. Intenta más tarde.',
    500: 'Error del servidor. Intenta más tarde.',
  };

  static const Map<String, Map<int, String>> _endpointErrorMessages = {
    _epSetRole: {
      400: 'Rol inválido o datos incompletos.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para asignar roles.',
      404: 'Usuario no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos actualizar el rol del usuario.',
    },
    _epGetUser: {
      400: 'Solicitud inválida al obtener el usuario.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para ver usuarios.',
      404: 'Usuario no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos obtener el usuario.',
    },
    _epCreateUser: {
      400: 'Datos inválidos para crear el usuario.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para crear usuarios.',
      404: 'Recurso no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos crear el usuario.',
    },
    _epUpdateUser: {
      400: 'Datos inválidos para actualizar el usuario.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para actualizar usuarios.',
      404: 'Usuario no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos actualizar el usuario.',
    },
    _epListUsers: {
      400: 'Filtros inválidos para listar usuarios.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para listar usuarios.',
      404: 'No se encontraron usuarios.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos obtener la lista de usuarios.',
    },
    _epListUserSessions: {
      400: 'Solicitud inválida al listar sesiones.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para ver sesiones.',
      404: 'Sesiones no encontradas.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos obtener las sesiones.',
    },
    _epBanUser: {
      400: 'Datos inválidos para banear el usuario.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para banear usuarios.',
      404: 'Usuario no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos banear el usuario.',
    },
    _epUnbanUser: {
      400: 'Solicitud inválida para quitar el baneo.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para quitar el baneo.',
      404: 'Usuario no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos quitar el baneo.',
    },
    _epImpersonateUser: {
      400: 'Solicitud inválida para impersonar al usuario.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para impersonar.',
      404: 'Usuario no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos iniciar la impersonación.',
    },
    _epStopImpersonating: {
      400: 'Solicitud inválida para detener la impersonación.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para detener la impersonación.',
      404: 'Impersonación no encontrada.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos detener la impersonación.',
    },
    _epRevokeUserSession: {
      400: 'Solicitud inválida para revocar la sesión.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para revocar sesiones.',
      404: 'Sesión no encontrada.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos revocar la sesión.',
    },
    _epRevokeUserSessions: {
      400: 'Solicitud inválida para revocar sesiones.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para revocar sesiones.',
      404: 'Sesiones no encontradas.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos revocar las sesiones.',
    },
    _epSetUserPassword: {
      400: 'Contraseña inválida o datos incompletos.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para cambiar contraseñas.',
      404: 'Usuario no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos actualizar la contraseña.',
    },
    _epHasPermission: {
      400: 'Solicitud inválida para verificar permisos.',
      401: 'Sesión expirada. Inicia sesión nuevamente.',
      403: 'No tienes permisos para esta acción.',
      404: 'Permiso no encontrado.',
      429: 'Demasiadas solicitudes. Intenta más tarde.',
      500: 'No pudimos verificar permisos.',
    },
  };

  // ============================================================
  // GESTIÓN DE ROLES
  // ============================================================

  /// Asigna un rol a un usuario.
  @override
  Future<AdminUserResponse> setRole({
    required String userId,
    required String role,
  }) async {
    try {
      final response = await _authService.adminSetRole(
        userId: userId,
        role: role,
      );
      return AdminUserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epSetRole);
    }
  }

  /// Verifica permisos del usuario actual.
  @override
  Future<AdminHasPermissionResponse> hasPermission({
    required Map<String, dynamic> permissions,
  }) async {
    try {
      final response = await _authService.adminHasPermission(
        permissions: permissions,
      );
      return AdminHasPermissionResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epHasPermission);
    }
  }

  // ============================================================
  // GESTIÓN DE USUARIOS (CRUD)
  // ============================================================

  /// Obtiene información de un usuario por ID.
  @override
  Future<AdminUserResponse> getUser({required String userId}) async {
    try {
      final response = await _authService.adminGetUser(id: userId);
      return AdminUserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epGetUser);
    }
  }

  /// Crea un nuevo usuario.
  @override
  Future<AdminUserResponse> createUser({
    required String email,
    required String password,
    required String name,
    String? role,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _authService.adminCreateUser(
        email: email,
        password: password,
        name: name,
        role: role,
        // data: data,
        data: {
          if (data != null) ...data,
        },
      );
      return AdminUserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epCreateUser);
    }
  }

  /// Actualiza datos de un usuario.
  @override
  Future<AdminUserResponse> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _authService.adminUpdateUser(
        userId: userId,
        data: data,
      );
      return AdminUserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epUpdateUser);
    }
  }

  /// Lista usuarios con paginación y filtros.
  @override
  Future<AdminListUsersResponse> listUsers({
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
      final response = await _authService.adminListUsers(
        searchValue: searchValue,
        limit: limit,
        offset: offset,
        sortBy: sortBy,
        sortDirection: sortDirection,
        filterField: filterField,
        filterOperator: filterOperator,
        filterValue: filterValue,
      );
      return AdminListUsersResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epListUsers);
    }
  }

  /// Establece contraseña de un usuario.
  @override
  Future<AdminSuccessResponse> setUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      final response = await _authService.adminSetUserPassword(
        userId: userId,
        newPassword: newPassword,
      );
      return AdminSuccessResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epSetUserPassword);
    }
  }

  // ============================================================
  // GESTIÓN DE SESIONES
  // ============================================================

  /// Lista sesiones de un usuario.
  @override
  Future<AdminListUserSessionsResponse> listUserSessions({
    required String userId,
  }) async {
    try {
      final response = await _authService.adminListUserSessions(userId: userId);
      return AdminListUserSessionsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epListUserSessions);
    }
  }

  /// Revoca una sesión específica.
  @override
  Future<AdminSuccessResponse> revokeUserSession({
    required String sessionToken,
  }) async {
    try {
      final response = await _authService.adminRevokeUserSession(
        sessionToken: sessionToken,
      );
      return AdminSuccessResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epRevokeUserSession);
    }
  }

  /// Revoca todas las sesiones de un usuario.
  @override
  Future<AdminSuccessResponse> revokeUserSessions({
    required String userId,
  }) async {
    try {
      final response = await _authService.adminRevokeUserSessions(
        userId: userId,
      );
      return AdminSuccessResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epRevokeUserSessions);
    }
  }

  // ============================================================
  // MODERACIÓN (BAN/UNBAN)
  // ============================================================

  /// Banea a un usuario.
  @override
  Future<AdminUserResponse> banUser({
    required String userId,
    String? banReason,
    int? banExpiresIn,
  }) async {
    try {
      final response = await _authService.adminBanUser(
        userId: userId,
        banReason: banReason,
        banExpiresIn: banExpiresIn,
      );
      return AdminUserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epBanUser);
    }
  }

  /// Quita el baneo de un usuario.
  @override
  Future<AdminUserResponse> unbanUser({required String userId}) async {
    try {
      final response = await _authService.adminUnbanUser(userId: userId);
      return AdminUserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epUnbanUser);
    }
  }

  // ============================================================
  // IMPERSONACIÓN
  // ============================================================

  /// Inicia impersonación de un usuario.
  @override
  Future<AdminImpersonateResponse> impersonateUser({
    required String userId,
  }) async {
    try {
      final response = await _authService.adminImpersonateUser(userId: userId);
      return AdminImpersonateResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epImpersonateUser);
    }
  }

  /// Termina la impersonación.
  @override
  Future<AdminStopImpersonatingResponse> stopImpersonating() async {
    try {
      final response = await _authService.adminStopImpersonating();
      return AdminStopImpersonatingResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint: _epStopImpersonating);
    }
  }

  // ============================================================
  // MANEJO DE ERRORES
  // ============================================================

  /// Convierte errores de Dio a excepciones de dominio.
  ///
  /// Mapea los códigos HTTP a tipos de error específicos:
  /// - 400: Bad request / Validación
  /// - 401: No autenticado
  /// - 403: Sin permisos de admin
  /// - 404: Usuario no encontrado
  /// - 429: Rate limit
  /// - 500+: Error del servidor
  AuthException _handleDioError(
    DioException e, {
    String? endpoint,
  }) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Extraer mensaje de error de la respuesta
    String message = 'Error desconocido';
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          'Error desconocido';
    } else if (e.message != null) {
      message = e.message!;
    }

    final friendlyMessage =
        _friendlyMessage(endpoint: endpoint, statusCode: statusCode);

    switch (statusCode) {
      case 400:
        return AuthException(friendlyMessage ?? message);
      case 401:
        return SessionExpiredException(
          friendlyMessage ?? 'Sesión expirada o no autenticado',
        );
      case 403:
        return AuthException(
          friendlyMessage ??
              'No tienes permisos de administrador para esta acción',
          code: 'forbidden',
        );
      case 404:
        return UserNotFoundException(
          friendlyMessage ?? 'Usuario no encontrado',
        );
      case 429:
        return AuthException(
          friendlyMessage ?? 'Demasiadas solicitudes. Intenta más tarde.',
          code: 'too-many-requests',
        );
      case 500:
      case 502:
      case 503:
        return ServerException(
          friendlyMessage ?? 'Error del servidor. Intenta más tarde.',
        );
      default:
        // Manejo por tipo de excepción Dio
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            return NetworkException('Tiempo de espera agotado');
          case DioExceptionType.connectionError:
            return NetworkException('Error de conexión. Verifica tu internet.');
          case DioExceptionType.cancel:
            return AuthException('Solicitud cancelada', code: 'cancelled');
          case DioExceptionType.badCertificate:
            return NetworkException('Error de certificado SSL');
          case DioExceptionType.badResponse:
            return ServerException(friendlyMessage ?? message);
          case DioExceptionType.unknown:
            return AuthException(friendlyMessage ?? message, code: 'unknown');
        }
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
