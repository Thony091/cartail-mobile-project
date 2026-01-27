
class UrgenciaTicketModel {
  final int id;
  final String nombre;

  UrgenciaTicketModel({
    required this.id,
    required this.nombre,
  });

  factory UrgenciaTicketModel.fromJson(Map<String, dynamic> json) {
    return UrgenciaTicketModel(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}