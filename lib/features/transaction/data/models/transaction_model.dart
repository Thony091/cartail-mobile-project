import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart';
import 'transaction_item_model.dart';

class TransactionModel {
  final int id;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int transactionId;
  final int? reservationId;
  final List<TransactionItem> items;

  TransactionModel({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.transactionId,
    this.reservationId,
    this.items = const [],
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      date: json['fecha'] != null
        ? DateTime.parse(json['fecha'] as String)
        : json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
      updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : DateTime.now(),
      transactionId: json['id_transaction'] as int? ?? json['id'] as int,
      reservationId: json['id_reservation'] as int?,
      items: json['items'] != null
        ? (json['items'] as List)
            .map((item) => TransactionItemModel.fromJson(item).toEntity())
            .toList()
        : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'id_transaction': transactionId,
      if (reservationId != null) 'id_reservation': reservationId,
      'items': items.map((item) => TransactionItemModel.fromEntity(item).toJson()).toList(),
    };
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
      transactionId: transactionId,
      reservationId: reservationId,
      items: items,
    );
  }

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      date: transaction.date,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      transactionId: transaction.transactionId,
      reservationId: transaction.reservationId,
      items: transaction.items,
    );
  }
}
