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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
        data: data,
      );
      return AdminUserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
    }
  }

  /// Quita el baneo de un usuario.
  @override
  Future<AdminUserResponse> unbanUser({required String userId}) async {
    try {
      final response = await _authService.adminUnbanUser(userId: userId);
      return AdminUserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
  AuthException _handleDioError(DioException e) {
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

    switch (statusCode) {
      case 400:
        return AuthException(message);
      case 401:
        return SessionExpiredException('Sesión expirada o no autenticado');
      case 403:
        return AuthException(
          'No tienes permisos de administrador para esta acción',
          code: 'forbidden',
        );
      case 404:
        return UserNotFoundException('Usuario no encontrado');
      case 429:
        return AuthException(
          'Demasiadas solicitudes. Intenta más tarde.',
          code: 'too-many-requests',
        );
      case 500:
      case 502:
      case 503:
        return ServerException('Error del servidor. Intenta más tarde.');
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
            return ServerException(message);
          case DioExceptionType.unknown:
            return AuthException(message, code: 'unknown');
        }
    }
  }
}
