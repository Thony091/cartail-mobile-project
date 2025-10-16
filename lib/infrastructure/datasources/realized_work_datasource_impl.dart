
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:portafolio_project/infrastructure/infrastructure.dart';

import '../../config/config.dart';
import '../../domain/domain.dart';

class RealizedWorkDatasourceImpl extends RealizedWorkDatasource {

  late final Dio dio;
  final String accessToken;

  RealizedWorkDatasourceImpl({
    required this.accessToken
  }) : dio = Dio(
    BaseOptions(
      baseUrl: Enviroment.baseUrl,
      headers: {
        'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
        'Authorization': 'Bearer $accessToken'
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

  Future<String> _uploadPhoto( String photo ) async {
    // final photosToUpload = photos.where((element) => element.contains('/') ).toList();
    // final photosToIgnore = photos.where((element) => !element.contains('/') ).toList();
    String photoToConvert;
    String newImage = "";
    if  ( !photo.startsWith('https') ) {
      photoToConvert = photo;
      newImage = await _uploadFile( photoToConvert );
    } 
    else if ( photo.startsWith('https') ) {
      newImage = photo;
    }
    return newImage;
  }

  @override
  Future<Works> createUpdateWorks(Map<String, dynamic> worksSimilar) async {
    try {
      final String? workId = worksSimilar['id'];
      final String method = (workId == null) ? 'POST' : 'PUT';
      final String url = (workId == null) ? '/example' : '/example/$workId';
      worksSimilar.remove('id');
      if ( worksSimilar['image'] != "" ) {
        worksSimilar['image'] = await _uploadPhoto( worksSimilar['image'] );
      }

      Works work = Works( id: '0', name: 'No encontrado', description: 'No encontrado', image: "");
      final response = await dio.request(
        url,
        data: worksSimilar,
        options: Options(
          method: method
        )
      );
      final data = response.data;
      if ( data is Map<String, dynamic> && data.containsKey('data') ){
        var workData = data['data'];
        if ( workData is Map<String, dynamic> ){
          final work = RealizedWorksMapper.jsonToEntity(workData);
          return work;
        }
      }
      return work;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteWork(String id) {

    try {
      
      return dio.delete('/example/$id');

    } catch (e) {
      throw Exception(e);
    }

  }

  @override
  Future<Works> getRealizedWorkById(String id) async {    
    try {
      final response = await dio.get('/example/$id');
      Works work = Works( id: '0', name: 'No encontrado', description: 'No encontrado', image: "");
      if (response.statusCode == 200){
        final data = response.data;
        if ( data is Map<String, dynamic> && data.containsKey('data') ){
          work = RealizedWorksMapper.jsonToEntity(data['data']);
          return work;
        }
      }
      return work;
    } on DioException catch (e) {
      if ( e.response!.statusCode == 404 )  throw RealizedWorkNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Works>> getRealizedWorks() async {
    try {
      final response = await dio.get('/example');
      final List<Works> works = [];
      if (response.statusCode == 200){        
        var data = response.data;
        if ( data is Map<String, dynamic> && data.containsKey('data') ){
          var worksData = data['data'];
          if ( worksData is List ){
            for ( final work in worksData ){
              works.add( RealizedWorksMapper.jsonToEntity(work) );
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




}