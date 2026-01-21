import '../entities/factura.dart';

abstract class FacturaRepository {
  Future<List<Factura>> getFacturas();
  Future<Factura> getFacturaById(String id);
  Future<Factura> createUpdateFactura(Map<String, dynamic> facturaLike);
  Future<void> deleteFactura(String id);
}
