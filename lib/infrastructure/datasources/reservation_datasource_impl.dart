
import 'package:dio/dio.dart';
import 'package:portafolio_project/infrastructure/infrastructure.dart';

import '../../config/config.dart';
import '../../domain/domain.dart';

class ReservationDatasourceImpl extends ReservationDatasource {

  late final Dio dio;
  final String accessToken;

  ReservationDatasourceImpl({

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

  @override
  Future<Reservation> createUpdateReservation( 
    String name, String rut, String email, String reservationDate, String reservationTime, String serviceName ) async {
    
      try {

        final data = {
          'name': name,
          'rut': rut,
          'email': email,
          'reservationDate': reservationDate,
          'reservationTime': reservationTime,
          'serviceName': serviceName,
        };
        final response = await dio.post( '/reservation', data: data );

        final reserva = ReservationMapper.jsonToEntity( response.data );

        return reserva;

      } catch (e) {
        throw Exception('Error al crear la reserva');
      }

  }

  @override
  Future<void> deleteReservation(String id) async {
    try {
      await dio.delete('/reservation/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Reservation> getReservationById(String id) async {
    try {
      final response = await dio.get('/reservation/$id');
      Reservation reservation = Reservation(
        id: '', name: '', rut: '', email: '', reservationDate: '', reservationTime: '', serviceName: ''
      );
      if ( response.statusCode == 200 ) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data') ){
          reservation = ReservationMapper.jsonToEntity(data['data']);
        }
      }
      return reservation;
    } on DioException catch (e) {
      if ( e.response!.statusCode == 404) throw ServiceNotFound();
      throw e;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Reservation>> getReservations() async {
    
    try {
      
      final response = await dio.get('/reservation');
      final List<Reservation> reservations = [];

      if( response.statusCode == 200 ){
        var data = response.data;
        if ( data is Map<String, dynamic> && data.containsKey('data') ){
          var reservationsData = data['data'];
          if ( reservationsData is List) {
            for ( final reservation in reservationsData ){
              reservations.add( ReservationMapper.jsonToEntity(reservation) );
            }
          }
        }
      }
      return reservations;
    } catch (e) {
      throw Exception('Error al obtener las reservas');
    }

  }

}