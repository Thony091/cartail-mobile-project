import '../../domain/entities/transaction_payment.dart';

class TransactionPaymentModel {
  final int id;
  final int transactionId;
  final int paymentMethodId;
  final int paymentStateId;
  final int amount;
  final DateTime createdAt;

  TransactionPaymentModel({
    required this.id,
    required this.transactionId,
    required this.paymentMethodId,
    required this.paymentStateId,
    required this.amount,
    required this.createdAt,
  });

  factory TransactionPaymentModel.fromJson(Map<String, dynamic> json) {
    return TransactionPaymentModel(
      id: json['id'] as int,
      transactionId: json['id_transaction'] as int,
      paymentMethodId: json['id_payment_method'] as int,
      paymentStateId: json['id_payment_state'] as int,
      amount: _parseInt(json['amount']),
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
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
      'id_transaction': transactionId,
      'id_payment_method': paymentMethodId,
      'id_payment_state': paymentStateId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TransactionPayment toEntity() {
    return TransactionPayment(
      id: id,
      transactionId: transactionId,
      paymentMethodId: paymentMethodId,
      paymentStateId: paymentStateId,
      amount: amount,
      createdAt: createdAt,
    );
  }

  factory TransactionPaymentModel.fromEntity(TransactionPayment payment) {
    return TransactionPaymentModel(
      id: payment.id,
      transactionId: payment.transactionId,
      paymentMethodId: payment.paymentMethodId,
      paymentStateId: payment.paymentStateId,
      amount: payment.amount,
      createdAt: payment.createdAt,
    );
  }
}
