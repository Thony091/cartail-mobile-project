import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_state.dart';
import '../../domain/entities/transaction_payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_datasource.dart';

class PaymentRepositoryImpl extends PaymentRepository {
  final PaymentDatasource datasource;

  PaymentRepositoryImpl(this.datasource);

  @override
  Future<List<PaymentMethod>> getPaymentMethods() {
    return datasource.getPaymentMethods();
  }

  @override
  Future<PaymentMethod> getPaymentMethodById(int id) {
    return datasource.getPaymentMethodById(id);
  }

  @override
  Future<List<PaymentState>> getPaymentStates() {
    return datasource.getPaymentStates();
  }

  @override
  Future<PaymentState> getPaymentStateById(int id) {
    return datasource.getPaymentStateById(id);
  }

  @override
  Future<List<TransactionPayment>> getTransactionPayments(int transactionId) {
    return datasource.getTransactionPayments(transactionId);
  }

  @override
  Future<TransactionPayment> createTransactionPayment(TransactionPayment payment) {
    return datasource.createTransactionPayment(payment);
  }

  @override
  Future<TransactionPayment> updateTransactionPayment(TransactionPayment payment) {
    return datasource.updateTransactionPayment(payment);
  }

  @override
  Future<void> deleteTransactionPayment(int id) {
    return datasource.deleteTransactionPayment(id);
  }
}
