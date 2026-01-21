class TransactionItem {
  final int id;
  final int quantity;
  final int unitPrice;
  final int subtotal;
  final int discount;
  final int transactionId;
  final int? productId;
  final int? serviceId;

  TransactionItem({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.discount,
    required this.transactionId,
    this.productId,
    this.serviceId,
  });
}
