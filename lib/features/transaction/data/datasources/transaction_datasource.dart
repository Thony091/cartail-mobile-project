import '../../domain/entities/transaction.dart';

abstract class TransactionDatasource {
  Future<List<Transaction>> getTransactions();
  Future<Transaction> getTransactionById(int id);
  Future<List<Transaction>> getTransactionsByReservation(int reservationId);
  Future<Transaction> createTransaction(Transaction transaction);
  Future<Transaction> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(int id);
}
