import '../models/admin_response_models.dart';

/// Interface para operaciones administrativas de autenticación.
///
/// Define los métodos para gestión de usuarios por parte de administradores.
/// Incluye operaciones como:
/// - Gestión de roles (asignar, verificar permisos)
/// - CRUD de usuarios (crear, leer, actualizar, eliminar)
/// - Gestión de sesiones (listar, revocar)
/// - Moderación (banear, desbanear)
/// - Impersonación (actuar como otro usuario)
///
/// Todas las operaciones requieren que el usuario actual tenga rol de admin.
/// El backend validará los permisos en cada llamada.
abstract class AdminAuthDatasource {
  // ============================================================
  // GESTIÓN DE ROLES
  // ============================================================

  /// Asigna un rol a un usuario.
  ///
  /// [userId] - ID del usuario a modificar.
  /// [role] - Nuevo rol a asignar ('admin', 'operator', 'user', 'guest').
  ///
  /// Retorna el usuario actualizado con su nuevo rol.
  /// Lanza excepción si el usuario actual no tiene permisos de admin.
  Future<AdminUserResponse> setRole({
    required String userId,
    required String role,
  });

  /// Verifica si el usuario actual tiene determinados permisos.
  ///
  /// [permissions] - Mapa con los permisos a verificar.
  /// Ejemplo: {'resource': 'users', 'action': 'delete'}
  ///
  /// Retorna un objeto indicando si tiene los permisos solicitados.
  Future<AdminHasPermissionResponse> hasPermission({
    required Map<String, dynamic> permissions,
  });

  // ============================================================
  // GESTIÓN DE USUARIOS (CRUD)
  // ============================================================

  /// Obtiene información detallada de un usuario por ID.
  ///
  /// [userId] - ID del usuario a consultar.
  ///
  /// Retorna los datos completos del usuario incluyendo campos de ban.
  Future<AdminUserResponse> getUser({required String userId});

  /// Crea un nuevo usuario desde el panel de administración.
  ///
  /// [email] - Email del nuevo usuario (único).
  /// [password] - Contraseña inicial del usuario.
  /// [name] - Nombre del usuario.
  /// [role] - Rol inicial (opcional, por defecto 'user').
  /// [data] - Datos adicionales del perfil (phone, rut, etc.).
  ///
  /// Retorna el usuario creado.
  Future<AdminUserResponse> createUser({
    required String email,
    required String password,
    required String name,
    String? role,
    Map<String, dynamic>? data,
  });

  /// Actualiza datos de un usuario existente.
  ///
  /// [userId] - ID del usuario a actualizar.
  /// [data] - Mapa con los campos a actualizar.
  /// Campos permitidos: name, email, image, phone, rut, birthday, etc.
  ///
  /// Retorna el usuario actualizado.
  Future<AdminUserResponse> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  });

  /// Lista usuarios con paginación y filtros opcionales.
  ///
  /// [searchValue] - Busca en nombre y email.
  /// [limit] - Cantidad máxima de resultados (default: 10).
  /// [offset] - Desplazamiento para paginación.
  /// [sortBy] - Campo por el cual ordenar.
  /// [sortDirection] - 'asc' o 'desc'.
  /// [filterField] - Campo para filtrar.
  /// [filterOperator] - Operador del filtro ('eq', 'contains', etc.).
  /// [filterValue] - Valor a filtrar.
  ///
  /// Retorna lista paginada de usuarios con metadatos.
  Future<AdminListUsersResponse> listUsers({
    String? searchValue,
    int? limit,
    int? offset,
    String? sortBy,
    String? sortDirection,
    String? filterField,
    String? filterOperator,
    String? filterValue,
  });

  /// Establece una nueva contraseña para un usuario.
  ///
  /// [userId] - ID del usuario.
  /// [newPassword] - Nueva contraseña a establecer.
  ///
  /// Útil para resetear contraseñas de usuarios sin email de recuperación.
  Future<AdminSuccessResponse> setUserPassword({
    required String userId,
    required String newPassword,
  });

  // ============================================================
  // GESTIÓN DE SESIONES
  // ============================================================

  /// Lista todas las sesiones activas de un usuario.
  ///
  /// [userId] - ID del usuario.
  ///
  /// Retorna lista de sesiones con información del dispositivo y expiración.
  Future<AdminListUserSessionsResponse> listUserSessions({
    required String userId,
  });

  /// Revoca una sesión específica de un usuario.
  ///
  /// [sessionToken] - Token de la sesión a revocar.
  ///
  /// Cierra forzosamente esa sesión particular.
  Future<AdminSuccessResponse> revokeUserSession({
    required String sessionToken,
  });

  /// Revoca todas las sesiones de un usuario.
  ///
  /// [userId] - ID del usuario.
  ///
  /// Cierra forzosamente todas las sesiones activas del usuario.
  /// Útil cuando se sospecha de una cuenta comprometida.
  Future<AdminSuccessResponse> revokeUserSessions({
    required String userId,
  });

  // ============================================================
  // MODERACIÓN (BAN/UNBAN)
  // ============================================================

  /// Banea a un usuario.
  ///
  /// [userId] - ID del usuario a banear.
  /// [banReason] - Razón del baneo (opcional, visible para el usuario).
  /// [banExpiresIn] - Duración del ban en segundos (opcional).
  ///   Si es null, el ban es permanente.
  ///
  /// Un usuario baneado no puede iniciar sesión ni usar la aplicación.
  Future<AdminUserResponse> banUser({
    required String userId,
    String? banReason,
    int? banExpiresIn,
  });

  /// Quita el baneo de un usuario.
  ///
  /// [userId] - ID del usuario a desbanear.
  ///
  /// Permite que el usuario vuelva a acceder a la aplicación.
  Future<AdminUserResponse> unbanUser({required String userId});

  // ============================================================
  // IMPERSONACIÓN
  // ============================================================

  /// Inicia sesión como otro usuario (impersonación).
  ///
  /// [userId] - ID del usuario a impersonar.
  ///
  /// Crea una sesión especial que permite actuar como el usuario objetivo.
  /// Las acciones quedan registradas como impersonación.
  /// Útil para debugging y soporte al cliente.
  ///
  /// IMPORTANTE: El token de impersonación se guarda automáticamente
  /// y reemplaza temporalmente el token del admin.
  Future<AdminImpersonateResponse> impersonateUser({
    required String userId,
  });

  /// Termina la sesión de impersonación.
  ///
  /// Restaura la sesión original del administrador.
  /// Debe llamarse cuando se termina de impersonar.
  Future<AdminStopImpersonatingResponse> stopImpersonating();
}
