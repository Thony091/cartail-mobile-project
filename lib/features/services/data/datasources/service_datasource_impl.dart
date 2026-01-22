import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/services.dart';
import '../errors/service_errors.dart';
import '../mappers/service_mapper.dart';
import 'services_datasources.dart';

class ServicesDatasourceImpl extends ServicesDatasource {
  late final Dio dio;
  final String accessToken;

  ServicesDatasourceImpl({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Enviroment.baseUrl,
          headers: {
            // 'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
            // 'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

  Future<String> _uploadFile(String path) async {
    try {
      // Leer el archivo de imagen como bytes
      final fileBytes = File(path).readAsBytesSync();
      // Codificar los bytes a Base64
      final base64Image = base64Encode(fileBytes);
      // Devolver la cadena Base64 de la imagen
      return base64Image;
    } catch (e) {
      throw Exception('Error al convertir la imagen a Base64: $e');
    }
  }

  Future<List<String>> _uploadPhotos(List<String> photos) async {
    // final photosToUpload = photos.where((element) => element.contains('/') ).toList();
    // final photosToIgnore = photos.where((element) => !element.contains('/') ).toList();
    final photosToConvert = photos
        .where((element) => !element.startsWith('https'))
        .toList();
    final photosToIgnore = photos
        .where((element) => element.startsWith('https'))
        .toList();
    // Crear una serie de Futures de conversión de imágenes a Base64
    final List<Future<String>> conversionJobs = photosToConvert
        .map((photoPath) => _uploadFile(photoPath))
        .toList();
    // Esperar a que todas las conversiones se completen
    final convertedImages = await Future.wait(conversionJobs);
    // Devolver las imágenes ignoradas seguidas de las imágenes convertidas a Base64
    return [...photosToIgnore, ...convertedImages];
  }

  @override
  Future<Services> createUpdateService(
    Map<String, dynamic> serviceSimilar,
  ) async {
    try {
      final String? serviceId = serviceSimilar['id'];
      final String method = (serviceId == null) ? 'POST' : 'PUT';
      final String url = (serviceId == null)
          ? '/servicio'
          : '/servicio/$serviceId';
      serviceSimilar.remove('id');

      // Procesar las imágenes (convertir a Base64 si son locales)
      if (serviceSimilar.containsKey('images') && serviceSimilar['images'] != null) {
        final images = serviceSimilar['images'] as List<String>;
        final convertedImages = await _uploadPhotos(images);
        // El backend espera 'imagen' (singular) con la primera imagen
        serviceSimilar['imagen'] = convertedImages.isNotEmpty ? convertedImages.first : '';
        serviceSimilar.remove('images');
      }

      final response = await dio.request(
        url,
        data: serviceSimilar,
        options: Options(method: method),
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
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          service = ServiceMapper.jsonToEntity(data['data']);
        }
      }
      return service;
    } catch (e) {
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
