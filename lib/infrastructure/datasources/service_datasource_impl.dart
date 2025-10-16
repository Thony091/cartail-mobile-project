import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:portafolio_project/domain/domain.dart';

import '../../config/config.dart';
import '../infrastructure.dart';

class ServicesDatasourceImpl extends ServicesDatasource {

  late final Dio dio;
  final String accessToken;

  ServicesDatasourceImpl({
    required this.accessToken
  }) : dio = Dio(
    BaseOptions(
      baseUrl: Enviroment.baseUrl,
      headers: {
        'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      }
    )
  );

  Future<String> _uploadFile( String path ) async {
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

  Future<List<String>> _uploadPhotos( List<String> photos ) async {
    // final photosToUpload = photos.where((element) => element.contains('/') ).toList();
    // final photosToIgnore = photos.where((element) => !element.contains('/') ).toList();
    final photosToConvert = photos.where((element) => !element.startsWith('https')).toList();
    final photosToIgnore = photos.where((element) => element.startsWith('https')).toList();
    // Crear una serie de Futures de conversión de imágenes a Base64
    final List<Future<String>> conversionJobs = photosToConvert.map((photoPath) => _uploadFile(photoPath)).toList();
    // Esperar a que todas las conversiones se completen
    final convertedImages = await Future.wait(conversionJobs);
    // Devolver las imágenes ignoradas seguidas de las imágenes convertidas a Base64
    return [...photosToIgnore,...convertedImages];
  }

  @override
  Future<Services> createUpdateService(Map<String, dynamic> serviceSimilar) async {
    try { 
      final String? serviceId = serviceSimilar['id'];
      final String method = (serviceId == null) ? 'POST' : 'PUT';
      final String url = (serviceId == null) ? '/service' : '/service/$serviceId';
      serviceSimilar.remove('id');
      serviceSimilar['images'] = await _uploadPhotos( serviceSimilar['images'] );
      final response = await dio.request(
        url,
        data: serviceSimilar,
        options: Options(
          method: method
        )
      );
      Services service = Services(
        id: '', name: '', description: '', minPrice: 0, maxPrice: 0, isActive: false, images: []
      );
      if ( response.statusCode == 200 ) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data') ){
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
      await dio.delete('/service/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Services> getServiceById(String id) async {
    try {
      final response = await dio.get('/service/$id');
      Services service = Services(
        id: '', name: '', description: '', minPrice: 0, maxPrice: 0, isActive: false, images: []
      );
      if ( response.statusCode == 200 ) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data') ){
          service = ServiceMapper.jsonToEntity(data['data']);
        }
      }
      return service;
    } on DioException catch (e) {
      if ( e.response!.statusCode == 404) throw ServiceNotFound();
      throw e;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Services>> getServices() async {
    try {
      final response = await dio.get('/service');
      final List<Services> services = [];
      if ( response.statusCode == 200 ) {
        var data = response.data;

        if (data is Map<String, dynamic> && data.containsKey('data') ){
          var servicesData = data['data'];
          if ( servicesData is List ){
            for ( final service in servicesData ){
              services.add( ServiceMapper.jsonToEntity(service) );
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

}