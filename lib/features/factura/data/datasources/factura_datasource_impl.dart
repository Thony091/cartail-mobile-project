import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/factura.dart';
import '../errors/factura_errors.dart';
import '../mappers/factura_mapper.dart';
import 'factura_datasource.dart';

class FacturaDatasourceImpl extends FacturaDatasource {
  late final Dio dio;
  final String accessToken;

  FacturaDatasourceImpl({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Enviroment.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

  @override
  Future<Factura> createUpdateFactura(Map<String, dynamic> facturaLike) async {
    try {
      final String? facturaId = facturaLike['id'];
      final String method = (facturaId == null) ? 'POST' : 'PATCH';
      final String url = (facturaId == null)
          ? '/factura'
          : '/factura/$facturaId';

      // Remove id if it exists in the map because it's in the URL for updates
      // or not needed for creation (backend generates it) if generic
      if (facturaLike.containsKey('id')) {
        facturaLike.remove('id');
      }
      facturaLike.removeWhere((key, value) => value == null);

      final response = await dio.request(
        url,
        data: facturaLike,
        options: Options(method: method),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          return FacturaMapper.jsonToEntity(data);
        }
      }
      return _emptyFactura();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteFactura(String id) async {
    try {
      await dio.delete('/factura/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Factura> getFacturaById(String id) async {
    try {
      final response = await dio.get('/factura/$id');

      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          return FacturaMapper.jsonToEntity(data);
        }
      }
      return _emptyFactura();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404)
        throw FacturaFetchError('Factura no encontrada');
      throw e;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Factura>> getFacturas() async {
    try {
      final response = await dio.get('/factura');
      if (response.statusCode == 200) {
        return _parseFacturas(response.data);
      }
      return [];
    } catch (e) {
      print('Error $e');
      return [];
    }
  }

  Factura _emptyFactura() {
    return Factura(
      id: '',
      identificadorFactura: '',
      fechaEmision: DateTime.now(),
      subtotal: 0,
      impuesto: 0,
      total: 0,
      estado: '',
      pdf: '',
      idTransaccion: 0,
    );
  }

  List<Factura> _parseFacturas(dynamic responseData) {
    final data = _extractData(responseData);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(FacturaMapper.jsonToEntity)
          .toList();
    }
    return [];
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
