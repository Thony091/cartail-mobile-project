
class UserFirestoreResponse {
    final String uid;
    final String nombre;
    final String rut;
    final String fechaNacimiento;
    final String email;
    final String telefono;
    final String direccion;
    final String contrasenia;
    final String imagenPerfil;
    final String bio;
    final bool isAdmin;


    UserFirestoreResponse({
        required this.uid,
        required this.nombre,
        required this.rut,
        required this.fechaNacimiento,
        required this.email,
        required this.telefono,
        required this.direccion,
        required this.contrasenia,
        required this.imagenPerfil,
        required this.bio,
        required this.isAdmin,
    });

    factory UserFirestoreResponse.fromJson(Map<String, dynamic> json) => UserFirestoreResponse(
        uid: json["uid"],
        nombre: json["name"],
        rut: json["rut"] ?? '',
        fechaNacimiento: json["birthday"] ?? '',
        email: json["email"] ?? '',
        telefono: json["phone"] ?? '',
        direccion: json["direccion"] ?? '',
        contrasenia: json["password"],
        imagenPerfil: json["ProfileImage"] ?? '',
        bio: json["bio"] ?? '',
        isAdmin: json["isAdmin"],
    );

    Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": nombre,
        "rut": rut,
        "birthay": fechaNacimiento,
        "email": email,
        "telefono": telefono,
        "direccion": direccion,
        "password": contrasenia,
        "ProfileImage": imagenPerfil,
        "bio": bio,
        "isAdmin": isAdmin,
    };
}
