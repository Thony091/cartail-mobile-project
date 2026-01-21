import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_datasource.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final TransactionDatasource datasource;

  TransactionRepositoryImpl(this.datasource);

  @override
  Future<List<Transaction>> getTransactions() {
    return datasource.getTransactions();
  }

  @override
  Future<Transaction> getTransactionById(int id) {
    return datasource.getTransactionById(id);
  }

  @override
  Future<List<Transaction>> getTransactionsByReservation(int reservationId) {
    return datasource.getTransactionsByReservation(reservationId);
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) {
    return datasource.createTransaction(transaction);
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) {
    return datasource.updateTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(int id) {
    return datasource.deleteTransaction(id);
  }
}
