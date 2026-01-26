import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../../shared/domain/entities/state.dart' as lookup;
import 'ticket_lookup_crud_datasource.dart';

class TicketLookupCrudDatasourceImpl extends TicketLookupCrudDatasource {
  final Dio dio;
  final String path;

  TicketLookupCrudDatasourceImpl({
    required this.path,
    required String accessToken,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: Enviroment.baseUrl,
            headers: {
              'Content-Type': 'application/json',
              if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
            },
          ),
        );

  @override
  Future<List<lookup.State>> getAll() async {
    try {
      final response = await dio.get(path);
      final data = _extractData(response.data);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(_mapState)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<lookup.State?> getById(int id) async {
    try {
      final response = await dio.get('$path/$id');
      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return _mapState(data);
      }
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map<String, dynamic>) {
          return _mapState(first);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<lookup.State?> create(String name) async {
    try {
      final response = await dio.post(path, data: {'nombre': name});
      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return _mapState(data);
      }
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map<String, dynamic>) {
          return _mapState(first);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<lookup.State?> update({required int id, required String name}) async {
    try {
      final response = await dio.patch('$path/$id', data: {'nombre': name});
      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return _mapState(data);
      }
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map<String, dynamic>) {
          return _mapState(first);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(int id) async {
    await dio.delete('$path/$id');
  }

  lookup.State _mapState(Map<String, dynamic> json) {
    final id = _parseInt(json['id']) ?? 0;
    final name = json['nombre'] as String? ??
        json['name'] as String? ??
        json['nivel'] as String? ??
        '';
    return lookup.State(id: id, name: name);
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        if (data.containsKey('data')) return data['data'];
        if (data.containsKey('items')) return data['items'];
        if (data.containsKey('rows')) return data['rows'];
        if (data.containsKey('results')) return data['results'];
      }
      return data;
    }
    return responseData;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    try {
      return int.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
