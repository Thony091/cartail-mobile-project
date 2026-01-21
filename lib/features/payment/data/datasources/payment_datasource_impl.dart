import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_state.dart';
import '../../domain/entities/transaction_payment.dart';
import '../errors/payment_errors.dart';
import '../mappers/payment_mapper.dart';
import 'payment_datasource.dart';

class PaymentDatasourceImpl extends PaymentDatasource {
  late final Dio dio;
  final String accessToken;

  PaymentDatasourceImpl({
    required this.accessToken
  }) : dio = Dio(
    BaseOptions(
      baseUrl: Enviroment.baseUrl,
      headers: {
        'x-api-key': 'ZvHNth6qgZ6LNnwtXwJX75Jk8YlXEZxX2AZvOFSW',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      }
    )
  );

  @override
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await dio.get('/payment-method');
      final List<PaymentMethod> methods = [];
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          var methodsData = data['data'];
          if (methodsData is List) {
            for (final method in methodsData) {
              methods.add(PaymentMapper.methodJsonToEntity(method));
            }
          }
        }
      }
      return methods;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Future<PaymentMethod> getPaymentMethodById(int id) async {
    try {
      final response = await dio.get('/payment-method/$id');
      PaymentMethod method = PaymentMethod(id: 0, name: '');
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          method = PaymentMapper.methodJsonToEntity(data['data']);
        }
      }
      return method;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) throw PaymentMethodNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<PaymentState>> getPaymentStates() async {
    try {
      final response = await dio.get('/payment-state');
      final List<PaymentState> states = [];
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          var statesData = data['data'];
          if (statesData is List) {
            for (final state in statesData) {
              states.add(PaymentMapper.stateJsonToEntity(state));
            }
          }
        }
      }
      return states;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Future<PaymentState> getPaymentStateById(int id) async {
    try {
      final response = await dio.get('/payment-state/$id');
      PaymentState state = PaymentState(id: 0, name: '');
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          state = PaymentMapper.stateJsonToEntity(data['data']);
        }
      }
      return state;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) throw PaymentStateNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<TransactionPayment>> getTransactionPayments(int transactionId) async {
    try {
      final response = await dio.get('/transaction-payment/transaction/$transactionId');
      final List<TransactionPayment> payments = [];
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          var paymentsData = data['data'];
          if (paymentsData is List) {
            for (final payment in paymentsData) {
              payments.add(PaymentMapper.transactionPaymentJsonToEntity(payment));
            }
          }
        }
      }
      return payments;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Future<TransactionPayment> createTransactionPayment(TransactionPayment payment) async {
    try {
      final paymentData = PaymentMapper.transactionPaymentEntityToJson(payment);
      paymentData.remove('id');

      final response = await dio.post(
        '/transaction-payment',
        data: paymentData,
      );

      TransactionPayment newPayment = TransactionPayment(
        id: 0,
        transactionId: 0,
        paymentMethodId: 0,
        paymentStateId: 0,
        amount: 0,
        createdAt: DateTime.now(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          newPayment = PaymentMapper.transactionPaymentJsonToEntity(data['data']);
        }
      }
      return newPayment;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<TransactionPayment> updateTransactionPayment(TransactionPayment payment) async {
    try {
      final paymentData = PaymentMapper.transactionPaymentEntityToJson(payment);
      final int paymentId = paymentData['id'];
      paymentData.remove('id');

      final response = await dio.put(
        '/transaction-payment/$paymentId',
        data: paymentData,
      );

      TransactionPayment updatedPayment = TransactionPayment(
        id: 0,
        transactionId: 0,
        paymentMethodId: 0,
        paymentStateId: 0,
        amount: 0,
        createdAt: DateTime.now(),
      );
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          updatedPayment = PaymentMapper.transactionPaymentJsonToEntity(data['data']);
        }
      }
      return updatedPayment;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteTransactionPayment(int id) async {
    try {
      await dio.delete('/transaction-payment/$id');
    } catch (e) {
      throw Exception(e);
    }
  }
}
