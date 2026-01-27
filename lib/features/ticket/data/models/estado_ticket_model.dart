
class EstadoTicketModel {
  final int id;
  final String nombre;

  EstadoTicketModel({
    required this.id,
    required this.nombre,
  });

  factory EstadoTicketModel.fromJson(Map<String, dynamic> json) {
    return EstadoTicketModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}