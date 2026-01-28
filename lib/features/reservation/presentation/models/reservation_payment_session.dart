import '../../domain/entities/reservation.dart';

class ReservationPaymentSession {
  final String paymentUrl;
  final Reservation reservation;

  const ReservationPaymentSession({
    required this.paymentUrl,
    required this.reservation,
  });
}
