import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../config/config.dart';
import '../../../shared/domain/entities/state.dart';
import 'ticket_lookup_datasource.dart';

class TicketLookupDatasourceImpl extends TicketLookupDatasource {
  final Dio dio;

  TicketLookupDatasourceImpl()
      : dio = Dio(
          BaseOptions(
            baseUrl: Enviroment.baseUrl,
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

  @override
  Future<List<State>> getTicketStates() => _fetchList('/estado-ticket');

  @override
  Future<List<State>> getTicketImportance() => _fetchList('/importancia-ticket');

  @override
  Future<List<State>> getTicketUrgency() => _fetchList('/urgencia-ticket');

  Future<List<State>> _fetchList(String path) async {
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
    } catch (e) {
      debugPrint('TicketLookupDatasourceImpl._fetchList() error for path=$path: $e');
      rethrow;
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
