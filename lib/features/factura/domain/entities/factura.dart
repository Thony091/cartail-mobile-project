class Factura {
  final String id;
  final String identificadorFactura;
  final DateTime fechaEmision;
  final int subtotal;
  final int impuesto;
  final int total;
  final String estado;
  final String pdf;
  final int idTransaccion;

  Factura({
    required this.id,
    required this.identificadorFactura,
    required this.fechaEmision,
    required this.subtotal,
    required this.impuesto,
    required this.total,
    required this.estado,
    required this.pdf,
    required this.idTransaccion,
  });
}
