import '../../domain/entities/factura.dart';

class FacturaMapper {
  static Factura jsonToEntity(Map<String, dynamic> json) => Factura(
    id: json['id'] ?? '',
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    total: (json['total'] as num?)?.toDouble() ?? 0.0,
    description: json['description'] ?? '',
  );
}
