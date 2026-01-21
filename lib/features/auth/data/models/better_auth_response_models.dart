import 'better_auth_user_model.dart';

/// Modelo de respuesta genérica con status.
/// Usado para endpoints que solo retornan { "status": true/false }
class StatusResponse {
  final bool status;
  final String? message;

  StatusResponse({
    required this.status,
    this.message,
  });

  factory StatusResponse.fromJson(Map<String, dynamic> json) {
    return StatusResponse(
      status: json['status'] as bool? ?? json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

/// Modelo de respuesta para sign-in.
/// Endpoint: POST /api/auth/sign-in/email
class SignInResponse {
  final String? token;
  final BetterAuthUserModel? user;
  final bool redirect;
  final String? url;

  SignInResponse({
    this.token,
    this.user,
    this.redirect = false,
    this.url,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      token: json['token'] as String?,
      user: json['user'] != null
          ? BetterAuthUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      redirect: json['redirect'] as bool? ?? false,
      url: json['url'] as String?,
    );
  }

  /// Verifica si el sign-in fue exitoso (tiene token y usuario)
  bool get isSuccess => token != null && user != null;
}

/// Modelo de respuesta para sign-up.
/// Endpoint: POST /api/auth/sign-up/email
class SignUpResponse {
  final String? token;
  final BetterAuthUserModel? user;

  SignUpResponse({
    this.token,
    this.user,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      token: json['token'] as String?,
      user: json['user'] != null
          ? BetterAuthUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Verifica si el registro fue exitoso (tiene usuario)
  bool get isSuccess => user != null;
}

/// Modelo de sesión del servidor.
/// Representa una sesión activa en el backend.
class SessionModel {
  final String id;
  final String token;
  final String userId;
  final DateTime expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ipAddress;
  final String? userAgent;
  final String? impersonatedBy;

  SessionModel({
    required this.id,
    required this.token,
    required this.userId,
    required this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.ipAddress,
    this.userAgent,
    this.impersonatedBy,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      token: json['token'] as String,
      userId: json['userId'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      impersonatedBy: json['impersonatedBy'] as String?,
    );
  }

  /// Verifica si la sesión ha expirado
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Modelo de respuesta para get-session.
/// Endpoint: GET /api/auth/get-session
class GetSessionResponse {
  final SessionModel session;
  final BetterAuthUserModel user;

  GetSessionResponse({
    required this.session,
    required this.user,
  });

  factory GetSessionResponse.fromJson(Map<String, dynamic> json) {
    return GetSessionResponse(
      session: SessionModel.fromJson(json['session'] as Map<String, dynamic>),
      user: BetterAuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Modelo de respuesta para verify-email.
/// Endpoint: GET /api/auth/verify-email
class VerifyEmailResponse {
  final BetterAuthUserModel user;
  final bool status;

  VerifyEmailResponse({
    required this.user,
    required this.status,
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(
      user: BetterAuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      status: json['status'] as bool? ?? true,
    );
  }
}

/// Modelo de respuesta para change-password.
/// Endpoint: POST /api/auth/change-password
class ChangePasswordResponse {
  final String? token;
  final BetterAuthUserModel user;

  ChangePasswordResponse({
    this.token,
    required this.user,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      token: json['token'] as String?,
      user: BetterAuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Modelo de respuesta para change-email.
/// Endpoint: POST /api/auth/change-email
class ChangeEmailResponse {
  final BetterAuthUserModel user;
  final bool status;
  final String? message;

  ChangeEmailResponse({
    required this.user,
    required this.status,
    this.message,
  });

  factory ChangeEmailResponse.fromJson(Map<String, dynamic> json) {
    return ChangeEmailResponse(
      user: BetterAuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      status: json['status'] as bool? ?? true,
      message: json['message'] as String?,
    );
  }
}

/// Modelo de respuesta para account-info.
/// Endpoint: GET /api/auth/account-info
class AccountInfoResponse {
  final AccountInfoUser user;
  final Map<String, dynamic>? data;

  AccountInfoResponse({
    required this.user,
    this.data,
  });

  factory AccountInfoResponse.fromJson(Map<String, dynamic> json) {
    return AccountInfoResponse(
      user: AccountInfoUser.fromJson(json['user'] as Map<String, dynamic>),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

/// Modelo simplificado de usuario para account-info
class AccountInfoUser {
  final String id;
  final String name;
  final String email;
  final String? image;
  final bool emailVerified;

  AccountInfoUser({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    required this.emailVerified,
  });

  factory AccountInfoUser.fromJson(Map<String, dynamic> json) {
    return AccountInfoUser(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String,
      image: json['image'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }
}

/// Modelo de respuesta para refresh-token.
/// Endpoint: POST /api/auth/refresh-token
class RefreshTokenResponse {
  final String? tokenType;
  final String? idToken;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  RefreshTokenResponse({
    this.tokenType,
    this.idToken,
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      tokenType: json['tokenType'] as String?,
      idToken: json['idToken'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      accessTokenExpiresAt: json['accessTokenExpiresAt'] != null
          ? DateTime.tryParse(json['accessTokenExpiresAt'] as String)
          : null,
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] != null
          ? DateTime.tryParse(json['refreshTokenExpiresAt'] as String)
          : null,
    );
  }

  /// Verifica si el refresh fue exitoso (tiene accessToken)
  bool get isSuccess => accessToken != null;
}

/// Modelo de respuesta para link-social.
/// Endpoint: POST /api/auth/link-social
class LinkSocialResponse {
  final String? url;
  final bool redirect;
  final bool status;

  LinkSocialResponse({
    this.url,
    this.redirect = false,
    this.status = false,
  });

  factory LinkSocialResponse.fromJson(Map<String, dynamic> json) {
    return LinkSocialResponse(
      url: json['url'] as String?,
      redirect: json['redirect'] as bool? ?? false,
      status: json['status'] as bool? ?? false,
    );
  }
}

/// Modelo de cuenta social vinculada.
/// Endpoint: GET /api/auth/list-accounts
class LinkedAccountModel {
  final String id;
  final String providerId;
  final String accountId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> scopes;

  LinkedAccountModel({
    required this.id,
    required this.providerId,
    required this.accountId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.scopes = const [],
  });

  factory LinkedAccountModel.fromJson(Map<String, dynamic> json) {
    return LinkedAccountModel(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      accountId: json['accountId'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      scopes: (json['scopes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

/// Modelo de respuesta para update-user.
/// Endpoint: POST /api/auth/update-user
class UpdateUserResponse {
  final BetterAuthUserModel user;

  UpdateUserResponse({required this.user});

  factory UpdateUserResponse.fromJson(Map<String, dynamic> json) {
    return UpdateUserResponse(
      user: BetterAuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
