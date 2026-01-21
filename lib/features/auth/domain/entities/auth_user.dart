import '../../../user/domain/entities/user_role.dart';

/// Entidad de usuario autenticado para better_auth
/// Esta es una representación agnóstica del proveedor de autenticación
class AuthUser {
  final String id;
  final String email;
  final String? name;
  final String? image;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Información adicional del perfil
  final String? phone;
  final String? rut;
  final String? birthday;
  final String? address;
  final String? bio;

  /// Rol del usuario en el sistema
  final UserRole role;

  const AuthUser({
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
    this.role = UserRole.user,
  });

  /// Verifica si el usuario es un invitado (no autenticado)
  bool get isGuest => role == UserRole.guest;

  /// Verifica si el usuario es un usuario regular
  bool get isUser => role == UserRole.user;

  /// Verifica si el usuario es un operario
  bool get isOperator => role == UserRole.operator;

  /// Verifica si el usuario es un administrador
  bool get isAdmin => role == UserRole.admin;

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? image,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phone,
    String? rut,
    String? birthday,
    String? address,
    String? bio,
    UserRole? role,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      image: image ?? this.image,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phone: phone ?? this.phone,
      rut: rut ?? this.rut,
      birthday: birthday ?? this.birthday,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      role: role ?? this.role,
    );
  }
}
