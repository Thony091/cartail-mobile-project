
class ImportanciaTicketModel {
  final int id;
  final String nombre;

  ImportanciaTicketModel({
    required this.id,
    required this.nombre,
  });

  factory ImportanciaTicketModel.fromJson(Map<String, dynamic> json) {
    return ImportanciaTicketModel(
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