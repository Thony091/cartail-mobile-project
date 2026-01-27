import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../../shared/domain/entities/state.dart';
import 'state_datasource.dart';

class StateDatasourceImpl extends StateDatasource {
  final Dio dio;

  StateDatasourceImpl({required String accessToken})
      : dio = Dio(
          BaseOptions(
            baseUrl: Enviroment.baseUrl,
            headers: {
              'Content-Type': 'application/json',
              if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
            },
          ),
        );

  @override
  Future<List<State>> getStates() async {
    try {
      final response = await dio.get('/estado-ticket');
      final data = _extractData(response.data);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(_mapState)
            .toList();
      }
      if (data is Map<String, dynamic>) {
        return [_mapState(data)];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<State?> getStateById(int id) async {
    try {
      final response = await dio.get('/estado-ticket/$id');
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
  Future<State?> createState(String name) async {
    try {
      final response = await dio.post('/estado-ticket', data: {'nombre': name});
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
  Future<State?> updateState({required int id, required String name}) async {
    try {
      final response = await dio.patch(
        '/estado-ticket/$id',
        data: {'nombre': name},
      );
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

  State _mapState(Map<String, dynamic> json) {
    final id = _parseInt(json['id']) ?? 0;
    final name = json['nombre'] as String? ??
        json['name'] as String? ??
        json['nivel'] as String? ??
        '';
    return State(id: id, name: name);
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
