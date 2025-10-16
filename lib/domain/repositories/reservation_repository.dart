import '../domain.dart';

abstract class ReservationRepository{
  
  Future<List<Reservation>> getReservations( );
  Future<Reservation> getReservationById( String id );
  Future<Reservation> createUpdateReservation( String name, String rut, String email, String reservationDate, String reservationTime, String serviceName );
  Future<void> deleteReservation( String id );
  
}