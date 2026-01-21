import 'package:portafolio_project/features/user/data/models/userdb_response.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';

class UserMapper {
  static User userDbToEntity(UserFirestoreResponse userFs) => User(
    uid: userFs.uid,
    nombre: userFs.nombre,
    rut: userFs.rut,
    fechaNacimiento: userFs.fechaNacimiento,
    email: userFs.email,
    telefono: userFs.telefono,
    direccion: userFs.direccion,
    password: userFs.contrasenia,
    imagenPerfil: userFs.imagenPerfil,
    bio: userFs.bio,
    role: _parseUserRole(userFs.role),
    isAdmin: userFs.isAdmin,
  );

  /// Convierte un string de rol a UserRole enum
  /// Por defecto retorna 'guest' para usuarios no reconocidos
  static UserRole _parseUserRole(String roleString) {
    return UserRole.values.firstWhere(
      (r) => r.name == roleString,
      orElse: () => UserRole.guest,
    );
  }
}
