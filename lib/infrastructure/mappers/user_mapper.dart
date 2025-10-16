
import '../../domain/domain.dart';
import '../infrastructure.dart';

class UserMapper {

  static User userDbToEntity( UserFirestoreResponse userFs) => User(
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
    isAdmin: userFs.isAdmin,
  );
}
