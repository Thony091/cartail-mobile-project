import 'user_role.dart';

class User {
  final String uid;
  final String nombre;
  final String rut;
  final String fechaNacimiento;
  final String email;
  final String telefono;
  final String direccion;
  final String password;
  final String imagenPerfil;
  final String bio;

  /// Rol del usuario en el sistema
  final UserRole role;

  /// @deprecated Use role instead. Mantenido por compatibilidad.
  @Deprecated('Use role instead')
  final bool isAdmin;

  User({
    required this.uid,
    required this.nombre,
    required this.rut,
    required this.fechaNacimiento,
    required this.email,
    required this.telefono,
    required this.direccion,
    required this.password,
    required this.imagenPerfil,
    required this.bio,
    required this.role,
    @Deprecated('Use role instead') required this.isAdmin,
  });

  /// Verifica si el usuario es un invitado (no autenticado)
  bool get isGuest => role == UserRole.guest;

  /// Verifica si el usuario es un usuario regular
  bool get isUser => role == UserRole.user;

  /// Verifica si el usuario es un operario
  bool get isOperator => role == UserRole.operator;

  /// Verifica si el usuario es un administrador
  bool get isAdministrator => role == UserRole.admin;
}
