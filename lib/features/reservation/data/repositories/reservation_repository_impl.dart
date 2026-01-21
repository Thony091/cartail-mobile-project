
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_datasources.dart';

class ReservationRepositoryImpl extends ReservationRepository {

  final ReservationDatasource reservationDatasource;

  ReservationRepositoryImpl(this.reservationDatasource);
  
  @override
  Future<Reservation> createUpdateReservation( String name, String rut, String email, String reservationDate, String reservationTime, String serviceName ) {
    return reservationDatasource.createUpdateReservation( name, rut, email, reservationDate, reservationTime, serviceName );
  }
  
  @override
  Future<void> deleteReservation(String id) {
    return reservationDatasource.deleteReservation(id);
  }
  
  @override
  Future<Reservation> getReservationById(String id) {
    return reservationDatasource.getReservationById(id);
  }
  
  @override
  Future<List<Reservation>> getReservations() {
    return reservationDatasource.getReservations(); 
  }


 
}
