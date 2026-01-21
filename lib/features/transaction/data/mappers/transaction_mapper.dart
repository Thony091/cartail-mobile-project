import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_item.dart';
import '../models/transaction_item_model.dart';

class TransactionMapper {
  static Transaction jsonToEntity(Map<String, dynamic> json) => Transaction(
    id: json['id'] as int,
    date: json['date'] != null
      ? DateTime.parse(json['date'] as String)
      : DateTime.now(),
    createdAt: json['created_at'] != null
      ? DateTime.parse(json['created_at'] as String)
      : DateTime.now(),
    updatedAt: json['updated_at'] != null
      ? DateTime.parse(json['updated_at'] as String)
      : DateTime.now(),
    transactionId: json['id_transaction'] as int,
    reservationId: json['id_reservation'] as int?,
    items: json['items'] != null
      ? (json['items'] as List)
          .map((item) => TransactionItemModel.fromJson(item).toEntity())
          .toList()
      : [],
  );

  static Map<String, dynamic> entityToJson(Transaction transaction) => {
    'id': transaction.id,
    'date': transaction.date.toIso8601String(),
    'created_at': transaction.createdAt.toIso8601String(),
    'updated_at': transaction.updatedAt.toIso8601String(),
    'id_transaction': transaction.transactionId,
    if (transaction.reservationId != null) 'id_reservation': transaction.reservationId,
    'items': transaction.items.map((item) => TransactionItemModel.fromEntity(item).toJson()).toList(),
  };

  static TransactionItem itemJsonToEntity(Map<String, dynamic> json) => TransactionItem(
    id: json['id'] as int,
    quantity: _parseInt(json['quantity']),
    unitPrice: _parseInt(json['unit_price']),
    subtotal: _parseInt(json['subtotal']),
    discount: _parseInt(json['discount']),
    transactionId: json['id_transaction'] as int,
    productId: json['id_product'] as int?,
    serviceId: json['id_service'] as int?,
  );

  static Map<String, dynamic> itemEntityToJson(TransactionItem item) => {
    'id': item.id,
    'quantity': item.quantity,
    'unit_price': item.unitPrice,
    'subtotal': item.subtotal,
    'discount': item.discount,
    'id_transaction': item.transactionId,
    if (item.productId != null) 'id_product': item.productId,
    if (item.serviceId != null) 'id_service': item.serviceId,
  };

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }
}
