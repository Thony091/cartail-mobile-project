import '../../domain/entities/auth_session.dart';
import 'better_auth_user_model.dart';

/// Modelo de respuesta de better_auth para sesiones
class BetterAuthSessionModel {
  final String token;
  final String? refreshToken;
  final BetterAuthUserModel user;
  final String? expiresAt;
  final String? createdAt;

  BetterAuthSessionModel({
    required this.token,
    this.refreshToken,
    required this.user,
    this.expiresAt,
    this.createdAt,
  });

  factory BetterAuthSessionModel.fromJson(Map<String, dynamic> json) {
    return BetterAuthSessionModel(
      token: json['token'] as String? ?? json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: BetterAuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: json['expiresAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'expiresAt': expiresAt,
      'createdAt': createdAt,
    };
  }

  /// Convierte el modelo a una entidad de dominio
  AuthSession toEntity() {
    return AuthSession(
      token: token,
      refreshToken: refreshToken,
      user: user.toEntity(),
      expiresAt: expiresAt != null
          ? DateTime.parse(expiresAt!)
          : DateTime.now().add(const Duration(hours: 24)),
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
    );
  }
}
