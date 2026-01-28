import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_payment_init.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_datasources.dart';

class ReservationRepositoryImpl extends ReservationRepository {
  ReservationRepositoryImpl({
    required ReservationDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final ReservationDatasource _remoteDatasource;

  @override
  Future<List<Reservation>> getReservations() {
    return _remoteDatasource.getReservations();
  }

  @override
  Future<Reservation> getReservationById(String id) {
    return _remoteDatasource.getReservationById(id);
  }

  @override
  Future<Reservation> createUpdateReservation(Map<String, dynamic> reservationSimilar) {
    return _remoteDatasource.createUpdateReservation(reservationSimilar);
  }

  @override
  Future<ReservationPaymentInit> iniciarPagoReserva(
    Map<String, dynamic> reservationSimilar,
  ) {
    return _remoteDatasource.pagarReserva(reservationSimilar);
  }

  @override
  Future<void> guardarReservaConfirmadaLocal(Reservation reservation) async {
    // No-op: Remote-only datasource, no local caching
  }

  @override
  Future<void> deleteReservation(String id) {
    return _remoteDatasource.deleteReservation(id);
  }
}
