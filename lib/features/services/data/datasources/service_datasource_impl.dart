import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../config/config.dart';
// import '../../../../config/constants/secure_storage_keys.dart';
// import '../../../../config/services/secure_storage_service.dart';
import '../../domain/entities/services.dart';
import '../errors/service_errors.dart';
import '../mappers/service_mapper.dart';
import 'services_datasources.dart';
import 'package:portafolio_project/core/utils/image_encoder_service.dart';

class ServicesDatasourceImpl extends ServicesDatasource {
  late final Dio dio;
  final String accessToken;
  final ImageEncoderService _imageEncoder;
  // final _secureStorage = SecureStorageService.instance;

  ServicesDatasourceImpl({
    required this.accessToken,
    ImageEncoderService? imageEncoder,
  })  : _imageEncoder = imageEncoder ?? const ImageEncoderService(),
        dio = Dio(
          BaseOptions(
            baseUrl: Enviroment.baseUrl,
            headers: {
              // 'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
              // 'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _attachAuthHeader();
  }

  void _attachAuthHeader() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // String? token = await _secureStorage.read(
          //   key: jwtStorageAccessTokenKey,
          // );
          // if (token == null || token.isEmpty) {
          String? token = accessToken.isNotEmpty ? accessToken : '';
          // }
          // if (token != null &&
          //     token.isNotEmpty &&
          //     !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          // }
          return handler.next(options);
        },
      ),
    );
  }

  Future<String?> _encodeImage(String photo) async {
    final trimmed = photo.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http')) return null;
    if (trimmed.startsWith('data:image/')) {
      return ImageEncoderService.stripDataUriPrefix(trimmed);
    }

    final normalizedPath = trimmed.startsWith('file://')
        ? Uri.parse(trimmed).toFilePath()
        : trimmed;

    final file = File(normalizedPath);
    if (await file.exists()) {
      return _imageEncoder.encodeFile(file);
    }
    return null;
  }

  Future<List<String>> _encodeImageCandidates(List<String> photos) async {
    final encoded = <String>[];
    for (final photo in photos) {
      try {
        final encodedPhoto = await _encodeImage(photo);
        if (encodedPhoto != null) {
          encoded.add(encodedPhoto);
        }
      } on ImageEncodingException catch (e) {
        debugPrint('ServicesDatasourceImpl image encoding failed for $photo: $e');
        rethrow;
      }
    }

    if (kDebugMode && encoded.isNotEmpty) {
      debugPrint(
        'ServicesDatasourceImpl encoded ${encoded.length} local image(s), first size ${encoded.first.length} chars',
      );
    }

    return encoded;
  }

  @override
  Future<Services> createUpdateService(
    Map<String, dynamic> serviceSimilar,
  ) async {
    try {
      final String? serviceId = serviceSimilar['id'];
      final String method = (serviceId == null) ? 'POST' : 'PATCH';
      final String url = (serviceId == null)
          ? '/servicio'
          : '/servicio/$serviceId';
      serviceSimilar.remove('id');

      // Procesar las imágenes (convertir a Base64 si son locales)
      if (serviceSimilar.containsKey('images') &&
          serviceSimilar['images'] is List) {
        final images = (serviceSimilar['images'] as List)
            .whereType<String>()
            .toList();
        final convertedImages = await _encodeImageCandidates(images);
        if (convertedImages.isNotEmpty) {
          // El backend espera 'imagen' (singular) con la primera imagen
          serviceSimilar['imagen'] = convertedImages.first;
        }
        serviceSimilar.remove('images');
      }

      final response = await dio.request(
        url,
        data: serviceSimilar,
        options: Options(
          method: method,
        ),
      );
      Services service = Services(
        id: '',
        name: '',
        description: '',
        minPrice: 0,
        maxPrice: 0,
        requiresReservation: false,
        isActive: false,
        images: [],
        durationMinutes: 0,
        categoryId: null,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          service = ServiceMapper.jsonToEntity(data);
        } else if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is Map<String, dynamic>) {
            service = ServiceMapper.jsonToEntity(first);
          }
        }
      }
      return service;
    } catch (e) {
      debugPrint('Error en createUpdateService: $e');
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteService(String id) async {
    try {
      await dio.delete('/servicio/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Services> getServiceById(String id) async {
    try {
      final response = await dio.get('/servicio/$id');
      Services service = Services(
        id: '',
        name: '',
        description: '',
        minPrice: 0,
        maxPrice: 0,
        requiresReservation: false,
        isActive: false,
        images: [],
        durationMinutes: 0,
        categoryId: null,
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          service = ServiceMapper.jsonToEntity(data);
        }
      }
      return service;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ServiceNotFound();
      throw e;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Services>> getServices() async {
    try {
      final response = await dio.get('/servicio');
      final List<Services> services = [];
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        if (data is List) {
          for (final service in data) {
            if (service is Map<String, dynamic>) {
              services.add(ServiceMapper.jsonToEntity(service));
            }
          }
        }
      }
      return services;
    } catch (e) {
      print('Error $e');
      return [];
    }
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
