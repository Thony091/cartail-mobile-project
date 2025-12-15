/// Enumeración que define los roles de usuario en el sistema.
///
/// Cada rol tiene permisos específicos para acceder a diferentes
/// funcionalidades de la aplicación.
enum UserRole {
  /// Invitado - Usuario no autenticado
  /// Puede ver contenido público pero no puede realizar acciones
  guest,

  /// Usuario - Usuario autenticado regular
  /// Puede realizar reservas, compras y ver su historial
  user,

  /// Operario - Personal operativo
  /// Puede ver y gestionar tickets asignados
  operator,

  /// Administrador - Control total del sistema
  /// Puede gestionar contenido, asignar tickets y ver todo el historial
  admin;

  /// Verifica si el rol puede gestionar contenido (servicios, productos, trabajos)
  bool get canManageContent => this == UserRole.admin;

  /// Verifica si el rol puede ver todos los tickets del sistema
  bool get canViewAllTickets => this == UserRole.admin;

  /// Verifica si el rol puede asignar tickets a operarios
  bool get canAssignTickets => this == UserRole.admin;

  /// Verifica si el rol puede ver tickets asignados
  bool get canViewAssignedTickets =>
      this == UserRole.operator || this == UserRole.admin;

  /// Verifica si el rol puede ver su propio historial
  bool get canViewOwnHistory => this != UserRole.guest;

  /// Verifica si el rol puede hacer reservas
  bool get canMakeReservations => this != UserRole.guest;

  /// Verifica si el rol puede realizar compras
  bool get canPurchase => this != UserRole.guest;

  /// Convierte el rol a string para almacenamiento
  String toJson() => name;

  /// Crea un UserRole desde un strings
  /// Por defecto retorna 'guest' para valores no reconocidos
  static UserRole fromJson(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.guest,
    );
  }
}
