import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_state.dart';
import '../../domain/entities/transaction_payment.dart';

class PaymentMapper {
  static PaymentMethod methodJsonToEntity(Map<String, dynamic> json) => PaymentMethod(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
  );

  static Map<String, dynamic> methodEntityToJson(PaymentMethod method) => {
    'id': method.id,
    'name': method.name,
  };

  static PaymentState stateJsonToEntity(Map<String, dynamic> json) => PaymentState(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
  );

  static Map<String, dynamic> stateEntityToJson(PaymentState state) => {
    'id': state.id,
    'name': state.name,
  };

  static TransactionPayment transactionPaymentJsonToEntity(Map<String, dynamic> json) => TransactionPayment(
    id: json['id'] as int,
    transactionId: json['id_transaction'] as int,
    paymentMethodId: json['id_payment_method'] as int,
    paymentStateId: json['id_payment_state'] as int,
    amount: _parseInt(json['amount']),
    createdAt: json['created_at'] != null
      ? DateTime.parse(json['created_at'] as String)
      : DateTime.now(),
  );

  static Map<String, dynamic> transactionPaymentEntityToJson(TransactionPayment payment) => {
    'id': payment.id,
    'id_transaction': payment.transactionId,
    'id_payment_method': payment.paymentMethodId,
    'id_payment_state': payment.paymentStateId,
    'amount': payment.amount,
    'created_at': payment.createdAt.toIso8601String(),
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
