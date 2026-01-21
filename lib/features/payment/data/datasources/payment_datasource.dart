import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_state.dart';
import '../../domain/entities/transaction_payment.dart';

abstract class PaymentDatasource {
  Future<List<PaymentMethod>> getPaymentMethods();
  Future<PaymentMethod> getPaymentMethodById(int id);

  Future<List<PaymentState>> getPaymentStates();
  Future<PaymentState> getPaymentStateById(int id);

  Future<List<TransactionPayment>> getTransactionPayments(int transactionId);
  Future<TransactionPayment> createTransactionPayment(TransactionPayment payment);
  Future<TransactionPayment> updateTransactionPayment(TransactionPayment payment);
  Future<void> deleteTransactionPayment(int id);
}
