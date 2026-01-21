import '../../domain/entities/factura.dart';
import '../../domain/repositories/factura_repository.dart';
import '../datasources/factura_datasource.dart';

class FacturaRepositoryImpl extends FacturaRepository {
  final FacturaDatasource datasource;

  FacturaRepositoryImpl(this.datasource);

  @override
  Future<Factura> createUpdateFactura(Map<String, dynamic> facturaLike) {
    return datasource.createUpdateFactura(facturaLike);
  }

  @override
  Future<void> deleteFactura(String id) {
    return datasource.deleteFactura(id);
  }

  @override
  Future<Factura> getFacturaById(String id) {
    return datasource.getFacturaById(id);
  }

  @override
  Future<List<Factura>> getFacturas() {
    return datasource.getFacturas();
  }
}
