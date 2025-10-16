class User{

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
  final bool   isAdmin;

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
    required this.isAdmin,
  });

  // bool get isAdmin { 
  //   return isAdmin;
  // }
}