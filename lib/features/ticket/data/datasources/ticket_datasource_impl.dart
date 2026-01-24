import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/ticket.dart';
import '../mappers/ticket_mapper.dart';
import 'ticket_datasource.dart';

class TicketDatasourceImpl extends TicketDatasource {
  late final Dio dio;
  final String accessToken;

  TicketDatasourceImpl({required this.accessToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: Enviroment.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            // 'Authorization': 'Bearer $accessToken',
          },
        ),
      );

  @override
  Future<Ticket> createUpdateTicket(Map<String, dynamic> ticketSimilar) async {
    try {
      final String? ticketId = ticketSimilar['id']?.toString();
      final String method = (ticketId == null) ? 'POST' : 'PATCH';
      final String url = (ticketId == null) ? '/ticket' : '/ticket/$ticketId';
      ticketSimilar.remove('id');
      ticketSimilar.removeWhere((key, value) => value == null);

      final response = await dio.request(
        url,
        data: ticketSimilar,
        options: Options(method: method),
      );

      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return TicketMapper.jsonToEntity(data);
      }

      return _emptyTicket();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteTicket(String id) async {
    try {
      await dio.delete('/ticket/$id');
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<Ticket> getTicketById(String id) async {
    try {
      final response = await dio.get('/ticket/$id');
      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return TicketMapper.jsonToEntity(data);
      }
      return _emptyTicket();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Ticket>> getTickets() async {
    try {
      final response = await dio.get('/ticket');
      final List<Ticket> tickets = [];
      final data = _extractData(response.data);
      if (data is List) {
        for (final ticket in data) {
          if (ticket is Map<String, dynamic>) {
            tickets.add(TicketMapper.jsonToEntity(ticket));
          }
        }
      }
      return tickets;
    } catch (e) {
      return [];
    }
  }

  Ticket _emptyTicket() {
    return Ticket(
      id: '0',
      userId: '',
      userName: '',
      type: TicketType.reservation,
      status: TicketStatus.pending,
      createdAt: DateTime.now(),
      title: '',
      description: '',
      metadata: const {},
    );
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
