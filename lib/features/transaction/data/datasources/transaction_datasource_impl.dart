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
        final data = _extractData(response.data);
        if (data is List) {
          for (final transaction in data) {
            if (transaction is Map<String, dynamic>) {
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
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          transaction = TransactionMapper.jsonToEntity(data);
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
        final data = _extractData(response.data);
        if (data is List) {
          for (final transaction in data) {
            if (transaction is Map<String, dynamic>) {
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
      final transactionData = {'fecha': transaction.date.toIso8601String()};

      final response = await dio.post('/transaccion', data: transactionData);

      Transaction newTransaction = Transaction(
        id: 0,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionId: 0,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          newTransaction = TransactionMapper.jsonToEntity(data);
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
      final transactionData = {'fecha': transaction.date.toIso8601String()};
      final int transactionId = transaction.id;

      final response = await dio.patch(
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
        final data = _extractData(response.data);
        if (data is Map<String, dynamic>) {
          updatedTransaction = TransactionMapper.jsonToEntity(data);
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

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
