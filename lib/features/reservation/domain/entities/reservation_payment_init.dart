class ReservationPaymentInit {
  final String paymentUrl;
  final String? reservationBackendId;
  final String? paymentId;

  const ReservationPaymentInit({
    required this.paymentUrl,
    this.reservationBackendId,
    this.paymentId,
  });
}
