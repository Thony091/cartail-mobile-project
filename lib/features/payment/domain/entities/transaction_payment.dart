class TransactionPayment {
  final int id;
  final int transactionId;
  final int paymentMethodId;
  final int paymentStateId;
  final int amount;
  final DateTime createdAt;

  TransactionPayment({
    required this.id,
    required this.transactionId,
    required this.paymentMethodId,
    required this.paymentStateId,
    required this.amount,
    required this.createdAt,
  });
}
