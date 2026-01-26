import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/works.dart';
import '../errors/work_error.dart';
import '../mappers/realized_work_mapper.dart';
import 'realized_work_datasources.dart';
import 'package:portafolio_project/core/utils/image_encoder_service.dart';

class RealizedWorkDatasourceImpl extends RealizedWorkDatasource {
  final ImageEncoderService _imageEncoder;
  late final Dio dio;
  final String accessToken;

  RealizedWorkDatasourceImpl({
    required this.accessToken,
    ImageEncoderService? imageEncoder,
  })  : _imageEncoder = imageEncoder ?? const ImageEncoderService(),
        dio = Dio(
          BaseOptions(
            baseUrl: Enviroment.baseUrl,
            headers: {
              // 'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
              // 'Authorization': 'Bearer $accessToken'
            },
          ),
        );

  Future<String> _preparePhoto(String photo) async {
    final trimmedPhoto = photo.trim();
    if (trimmedPhoto.isEmpty) return '';
    if (trimmedPhoto.startsWith('http')) return trimmedPhoto;
    if (trimmedPhoto.startsWith('data:image/')) {
      return ImageEncoderService.stripDataUriPrefix(trimmedPhoto);
    }

    final normalizedPath = trimmedPhoto.startsWith('file://')
        ? Uri.parse(trimmedPhoto).toFilePath()
        : trimmedPhoto;
    final file = File(normalizedPath);
    if (await file.exists()) {
      return _imageEncoder.encodeFile(file);
    }
    return ImageEncoderService.stripDataUriPrefix(trimmedPhoto);
  }

  @override
  Future<Works> createUpdateWorks(Map<String, dynamic> worksSimilar) async {
    try {
      final String? workId = worksSimilar['id'];
      final String method = (workId == null) ? 'POST' : 'PATCH';
      final String url = (workId == null)
          ? '/ejemplo'
          : '/ejemplo/$workId';
      final payload = Map<String, dynamic>.from(worksSimilar);
      payload.remove('id');

      if (payload.containsKey('image') && payload['image'] is String) {
        payload['imagen_despues'] = payload['image'];
        payload.remove('image');
      }

      if (payload['imagen_antes'] is String &&
          payload['imagen_antes'] != "") {
        payload['imagen_antes'] =
            await _preparePhoto(payload['imagen_antes']);
      }
      if (payload['imagen_despues'] is String &&
          payload['imagen_despues'] != "") {
        payload['imagen_despues'] =
            await _preparePhoto(payload['imagen_despues']);
      }

      payload['titulo'] ??= payload['name'] ?? '';
      payload['descripcion'] ??= payload['description'] ?? '';
      payload['testimonio'] ??= '';
      payload['calificacion'] ??= 1;
      payload['destacado'] ??= false;
      payload['activo'] ??= true;
      payload['fecha'] = _normalizeDate(payload['fecha']?.toString() ?? '');
      payload['id_modelo_vehiculo'] =
          _normalizeInt(payload['id_modelo_vehiculo'], defaultValue: 1);

      _normalizeImageFields(payload);
      _logImagePayload(payload);

      final fallbackWork = _workFromPayload(payload, workId: workId);
      final response = await dio.request(
        url,
        data: payload,
        options: Options(method: method),
      );
      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        final work = RealizedWorksMapper.jsonToEntity(data);
        return work;
      }
      return fallbackWork;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteWork(String id) {
    try {
      return dio.delete('/ejemplo/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Works> getRealizedWorkById(String id) async {
    try {
      final response = await dio.get('/ejemplo/$id');
      Works work = Works(
        id: '0',
        name: 'No encontrado',
        description: 'No encontrado',
        image: "",
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          work = RealizedWorksMapper.jsonToEntity(data);
          return work;
        }
      }
      return work;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw RealizedWorkNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Works>> getRealizedWorks() async {
    try {
      final response = await dio.get('/ejemplo');
      final List<Works> works = [];
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is List) {
          for (final work in data) {
            if (work is Map<String, dynamic>) {
              works.add(RealizedWorksMapper.jsonToEntity(work));
            }
          }
        }
      }
      return works;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  String _normalizeDate(String value) {
    if (value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return parsed.toIso8601String();
  }

  int _normalizeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    final parsed = int.tryParse(value.toString());
    return parsed ?? defaultValue;
  }

  void _normalizeImageFields(Map<String, dynamic> payload) {
    const fields = ['imagen_antes', 'imagen_despues'];
    for (final field in fields) {
      final value = payload[field];
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) {
          payload.remove(field);
        } else {
          payload[field] = trimmed;
        }
      }
    }
  }

  void _logImagePayload(Map<String, dynamic> payload) {
    if (!kDebugMode) return;
    final info = <String>[];
    for (final field in ['imagen_antes', 'imagen_despues']) {
      final value = payload[field];
      if (value is String && value.isNotEmpty) {
        info.add('$field:${value.length}');
      }
    }
    if (info.isNotEmpty) {
      debugPrint('RealizedWork payload image lengths: ${info.join(', ')}');
    }
  }

  Works _workFromPayload(Map<String, dynamic> payload, {String? workId}) {
    return Works(
      id: workId ?? 'new',
      name: payload['titulo']?.toString() ?? '',
      description: payload['descripcion']?.toString() ?? '',
      image: payload['imagen_despues']?.toString() ??
          payload['imagen_antes']?.toString() ??
          '',
      testimonial: payload['testimonio']?.toString() ?? '',
      rating: _normalizeInt(payload['calificacion'], defaultValue: 1),
      isFeatured: payload['destacado'] == true,
      isActive: payload['activo'] != false,
      date: payload['fecha']?.toString() ?? '',
      vehicleModelId: _normalizeInt(payload['id_modelo_vehiculo']),
      beforeImage: payload['imagen_antes']?.toString() ?? '',
      afterImage: payload['imagen_despues']?.toString() ?? '',
    );
  }
}
