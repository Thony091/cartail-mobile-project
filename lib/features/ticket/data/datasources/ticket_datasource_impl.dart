import 'package:dio/dio.dart';

import '../../../../config/config.dart';
import '../../domain/entities/estado_ticket.dart';
import '../../domain/entities/importancia_ticket.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/urgencia_ticket.dart';
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
            if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'createUpdateTicket failed with status ${response.statusCode}',
        );
      }

      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return TicketMapper.jsonToEntity(data);
      }
      throw Exception('createUpdateTicket returned empty payload');
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
      print('✅ TicketDatasource.getTickets() response: ${response.statusCode}');
      final List<Ticket> tickets = [];
      final data = _extractData(response.data);
      print('📦 Extracted data type: ${data.runtimeType}, length: ${data is List ? data.length : 'N/A'}');
      if (data is List) {
        for (final ticket in data) {
          if (ticket is Map<String, dynamic>) {
            final mapped = TicketMapper.jsonToEntity(ticket);
            print('🎫 Mapped ticket: id=${mapped.id}, nombre=${mapped.nombre}');
            tickets.add(mapped);
          }
        }
      }
      print('✅ TicketDatasource.getTickets() returning ${tickets.length} tickets');
      return tickets;
    } catch (e) {
      print('❌ TicketDatasource.getTickets() error: $e');
      rethrow;
    }
  }

  Ticket _emptyTicket() {
    return Ticket(
      id: 0,
      nombre: '',
      description: '',
      desde: null,
      hasta: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      idServicio: 1,
      idUser: null,
      idReserva: '',
      estado: EstadoTicket(id: 1, nombre: ''),
      importancia: ImportanciaTicket(id: 1, nombre: ''),
      urgencia: UrgenciaTicket(id: 1, nombre: ''),
    );
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
