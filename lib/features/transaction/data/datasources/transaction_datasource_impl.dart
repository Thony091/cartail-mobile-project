import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/transaction.dart';
import '../errors/transaction_errors.dart';
import '../mappers/transaction_mapper.dart';
import 'transaction_datasource.dart';

class TransactionDatasourceImpl extends TransactionDatasource {
  late final Dio dio;
  final String accessToken;

  TransactionDatasourceImpl({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Enviroment.baseUrl,
          headers: {
            // 'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
            // 'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

  @override
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await dio.get('/transaccion');
      final List<Transaction> transactions = [];
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          var transactionsData = data['data'];
          if (transactionsData is List) {
            for (final transaction in transactionsData) {
              transactions.add(TransactionMapper.jsonToEntity(transaction));
            }
          }
        }
      }
      return transactions;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Future<Transaction> getTransactionById(int id) async {
    try {
      final response = await dio.get('/transaccion/$id');
      Transaction transaction = Transaction(
        id: 0,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionId: 0,
      );
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          transaction = TransactionMapper.jsonToEntity(data['data']);
        }
      }
      return transaction;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) throw TransactionNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByReservation(
    int reservationId,
  ) async {
    try {
      final response = await dio.get('/transaccion/reserva/$reservationId');
      final List<Transaction> transactions = [];
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          var transactionsData = data['data'];
          if (transactionsData is List) {
            for (final transaction in transactionsData) {
              transactions.add(TransactionMapper.jsonToEntity(transaction));
            }
          }
        }
      }
      return transactions;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final transactionData = TransactionMapper.entityToJson(transaction);
      transactionData.remove('id');

      final response = await dio.post('/transaccion', data: transactionData);

      Transaction newTransaction = Transaction(
        id: 0,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionId: 0,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          newTransaction = TransactionMapper.jsonToEntity(data['data']);
        }
      }
      return newTransaction;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      final transactionData = TransactionMapper.entityToJson(transaction);
      final int transactionId = transactionData['id'];
      transactionData.remove('id');

      final response = await dio.put(
        '/transaccion/$transactionId',
        data: transactionData,
      );

      Transaction updatedTransaction = Transaction(
        id: 0,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionId: 0,
      );
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          updatedTransaction = TransactionMapper.jsonToEntity(data['data']);
        }
      }
      return updatedTransaction;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteTransaction(int id) async {
    try {
      await dio.delete('/transaccion/$id');
    } catch (e) {
      throw Exception(e);
    }
  }
}
