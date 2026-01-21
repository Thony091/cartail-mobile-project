import '../../domain/entities/transaction_item.dart';

class TransactionItemModel {
  final int id;
  final int quantity;
  final int unitPrice;
  final int subtotal;
  final int discount;
  final int transactionId;
  final int? productId;
  final int? serviceId;

  TransactionItemModel({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.discount,
    required this.transactionId,
    this.productId,
    this.serviceId,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'] as int,
      quantity: _parseInt(json['quantity']),
      unitPrice: _parseInt(json['unit_price']),
      subtotal: _parseInt(json['subtotal']),
      discount: _parseInt(json['discount']),
      transactionId: json['id_transaction'] as int,
      productId: json['id_product'] as int?,
      serviceId: json['id_service'] as int?,
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'discount': discount,
      'id_transaction': transactionId,
      if (productId != null) 'id_product': productId,
      if (serviceId != null) 'id_service': serviceId,
    };
  }

  TransactionItem toEntity() {
    return TransactionItem(
      id: id,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      discount: discount,
      transactionId: transactionId,
      productId: productId,
      serviceId: serviceId,
    );
  }

  factory TransactionItemModel.fromEntity(TransactionItem item) {
    return TransactionItemModel(
      id: item.id,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      subtotal: item.subtotal,
      discount: item.discount,
      transactionId: item.transactionId,
      productId: item.productId,
      serviceId: item.serviceId,
    );
  }
}
