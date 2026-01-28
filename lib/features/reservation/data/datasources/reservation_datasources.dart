
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_payment_init.dart';

abstract class ReservationDatasource {
  
  Future<List<Reservation>> getReservations();
  Future<Reservation> getReservationById( String id );
  Future<Reservation> createUpdateReservation( Map<String, dynamic> reservationSimilar );
  Future<ReservationPaymentInit> pagarReserva( Map<String, dynamic> reservationSimilar );
  Future<void> deleteReservation( String id );
  
}
