import 'better_auth_response_models.dart' show SessionModel;
import 'better_auth_user_model.dart';

/// Modelo de usuario con información extendida de admin.
/// Incluye campos de baneo que no están en el usuario normal.
class AdminUserModel {
  final String id;
  final String? name;
  final String email;
  final bool emailVerified;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? role;
  final bool banned;
  final String? banReason;
  final DateTime? banExpires;

  AdminUserModel({
    required this.id,
    this.name,
    required this.email,
    this.emailVerified = false,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.banned = false,
    this.banReason,
    this.banExpires,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
      image: json['image'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      role: json['role'] as String?,
      banned: json['banned'] as bool? ?? false,
      banReason: json['banReason'] as String?,
      banExpires: json['banExpires'] != null
          ? DateTime.tryParse(json['banExpires'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'emailVerified': emailVerified,
      'image': image,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'role': role,
      'banned': banned,
      'banReason': banReason,
      'banExpires': banExpires?.toIso8601String(),
    };
  }

  /// Convierte a BetterAuthUserModel para reutilizar el toEntity()
  BetterAuthUserModel toBetterAuthUserModel() {
    return BetterAuthUserModel(
      id: id,
      email: email,
      name: name,
      image: image,
      emailVerified: emailVerified,
      createdAt: createdAt?.toIso8601String(),
      updatedAt: updatedAt?.toIso8601String(),
      role: role,
    );
  }

  /// Verifica si el usuario está actualmente baneado
  bool get isCurrentlyBanned {
    if (!banned) return false;
    if (banExpires == null) return true; // Ban permanente
    return DateTime.now().isBefore(banExpires!);
  }
}

/// Respuesta para operaciones que retornan un usuario.
/// Usado por: set-role, get-user, create-user, update-user, ban-user, unban-user
class AdminUserResponse {
  final AdminUserModel user;

  AdminUserResponse({required this.user});

  factory AdminUserResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserResponse(
      user: AdminUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Respuesta para list-users con paginación.
class AdminListUsersResponse {
  final List<AdminUserModel> users;
  final int total;
  final int limit;
  final int offset;

  AdminListUsersResponse({
    required this.users,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory AdminListUsersResponse.fromJson(Map<String, dynamic> json) {
    return AdminListUsersResponse(
      users: (json['users'] as List<dynamic>)
          .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 10,
      offset: json['offset'] as int? ?? 0,
    );
  }

  /// Calcula el número total de páginas
  int get totalPages => (total / limit).ceil();

  /// Calcula la página actual (basado en 0)
  int get currentPage => (offset / limit).floor();

  /// Verifica si hay más páginas
  bool get hasMore => offset + users.length < total;
}

/// Respuesta para list-user-sessions.
class AdminListUserSessionsResponse {
  final List<SessionModel> sessions;

  AdminListUserSessionsResponse({required this.sessions});

  factory AdminListUserSessionsResponse.fromJson(Map<String, dynamic> json) {
    return AdminListUserSessionsResponse(
      sessions: (json['sessions'] as List<dynamic>)
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Respuesta para impersonate-user.
class AdminImpersonateResponse {
  final SessionModel session;
  final AdminUserModel user;

  AdminImpersonateResponse({
    required this.session,
    required this.user,
  });

  factory AdminImpersonateResponse.fromJson(Map<String, dynamic> json) {
    return AdminImpersonateResponse(
      session: SessionModel.fromJson(json['session'] as Map<String, dynamic>),
      user: AdminUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Respuesta para stop-impersonating.
class AdminStopImpersonatingResponse {
  final String message;

  AdminStopImpersonatingResponse({required this.message});

  factory AdminStopImpersonatingResponse.fromJson(Map<String, dynamic> json) {
    return AdminStopImpersonatingResponse(
      message: json['message'] as String? ?? '',
    );
  }
}

/// Respuesta para has-permission.
class AdminHasPermissionResponse {
  final bool success;
  final String? error;

  AdminHasPermissionResponse({
    required this.success,
    this.error,
  });

  factory AdminHasPermissionResponse.fromJson(Map<String, dynamic> json) {
    return AdminHasPermissionResponse(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }

  /// Verifica si tiene el permiso
  bool get hasPermission => success && error == null;
}

/// Respuesta genérica de éxito para operaciones admin.
/// Usado por: revoke-user-session, revoke-user-sessions
class AdminSuccessResponse {
  final bool success;

  AdminSuccessResponse({required this.success});

  factory AdminSuccessResponse.fromJson(Map<String, dynamic> json) {
    return AdminSuccessResponse(
      success: json['success'] as bool? ?? json['status'] as bool? ?? false,
    );
  }
}
