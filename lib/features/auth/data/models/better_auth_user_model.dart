import '../../../user/domain/entities/user_role.dart';
import '../../domain/entities/auth_user.dart';

/// Modelo de respuesta de better_auth para usuarios
class BetterAuthUserModel {
  final String id;
  final String email;
  final String? name;
  final String? image;
  final bool emailVerified;
  final String? createdAt;
  final String? updatedAt;

  /// Campos adicionales del perfil
  final String? phone;
  final String? rut;
  final String? birthday;
  final String? address;
  final String? bio;
  final String? role;

  BetterAuthUserModel({
    required this.id,
    required this.email,
    this.name,
    this.image,
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
    this.phone,
    this.rut,
    this.birthday,
    this.address,
    this.bio,
    this.role,
  });

  factory BetterAuthUserModel.fromJson(Map<String, dynamic> json) {
    return BetterAuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      image: json['image'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      phone: json['phone'] as String?,
      rut: json['rut'] as String?,
      birthday: json['birthday'] as String?,
      address: json['address'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'image': image,
      'emailVerified': emailVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'phone': phone,
      'rut': rut,
      'birthday': birthday,
      'address': address,
      'bio': bio,
      'role': role,
    };
  }

  /// Convierte el modelo a una entidad de dominio
  AuthUser toEntity() {
    return AuthUser(
      id: id,
      email: email,
      name: name,
      image: image,
      emailVerified: emailVerified,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      phone: phone,
      rut: rut,
      birthday: birthday,
      address: address,
      bio: bio,
      role: _parseUserRole(role),
    );
  }

  /// Parsea el rol del usuario desde string
  UserRole _parseUserRole(String? roleStr) {
    if (roleStr == null) return UserRole.user;

    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'operator':
        return UserRole.operator;
      case 'user':
        return UserRole.user;
      case 'guest':
        return UserRole.guest;
      default:
        return UserRole.user;
    }
  }
}
