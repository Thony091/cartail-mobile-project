import 'transaction_item.dart';

class Transaction {
  final int id;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int transactionId;
  final int? reservationId;
  final List<TransactionItem> items;

  Transaction({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.transactionId,
    this.reservationId,
    this.items = const [],
  });

  int get total => items.fold(0, (sum, item) => sum + item.subtotal);
}
