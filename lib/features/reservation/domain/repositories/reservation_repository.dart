
import '../entities/reservation.dart';
import '../entities/reservation_payment_init.dart';

abstract class ReservationRepository{
  
  Future<List<Reservation>> getReservations( );
  Future<Reservation> getReservationById( String id );
  Future<Reservation> createUpdateReservation( Map<String, dynamic> reservationSimilar );
  Future<ReservationPaymentInit> iniciarPagoReserva( Map<String, dynamic> reservationSimilar );
  Future<void> guardarReservaConfirmadaLocal( Reservation reservation );
  Future<void> deleteReservation( String id );
  
}
