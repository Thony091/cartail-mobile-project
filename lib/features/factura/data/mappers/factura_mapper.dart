import '../../domain/entities/factura.dart';

class FacturaMapper {
  static Factura jsonToEntity(Map<String, dynamic> json) => Factura(
    id: json['id']?.toString() ?? '',
    identificadorFactura: json['identificadorFactura']?.toString() ?? '',
    fechaEmision: DateTime.tryParse(
          json['fechaEmision']?.toString() ?? '',
        ) ??
        DateTime.now(),
    subtotal: (json['subtotal'] as num?)?.round() ?? 0,
    impuesto: (json['impuesto'] as num?)?.round() ?? 0,
    total: (json['total'] as num?)?.round() ?? 0,
    estado: json['estado']?.toString() ?? '',
    pdf: json['pdf']?.toString() ?? '',
    idTransaccion: (json['idTransaccion'] as num?)?.round() ?? 0,
  );
}
