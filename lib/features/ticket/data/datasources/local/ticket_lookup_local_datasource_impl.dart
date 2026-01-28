import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/domain/entities/state.dart' as lookup;
import '../../../../shared/data/models/isar_domain_models.dart';
import 'ticket_lookup_local_datasource.dart';

class TicketLookupLocalDatasourceImpl extends TicketLookupLocalDatasource {
  TicketLookupLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  @override
  Future<List<lookup.State>> getEstados() async {
    final models = await _isar.ticketLookupModels
        .where()
        .typeEqualTo('estado')
        .findAll();
    return models
        .map((m) => lookup.State(id: m.backendId, name: m.name))
        .toList();
  }

  @override
  Future<List<lookup.State>> getImportancias() async {
    final models = await _isar.ticketLookupModels
        .where()
        .typeEqualTo('importancia')
        .findAll();
    return models
        .map((m) => lookup.State(id: m.backendId, name: m.name))
        .toList();
  }

  @override
  Future<List<lookup.State>> getUrgencias() async {
    final models = await _isar.ticketLookupModels
        .where()
        .typeEqualTo('urgencia')
        .findAll();
    return models
        .map((m) => lookup.State(id: m.backendId, name: m.name))
        .toList();
  }

  @override
  Future<void> cacheEstados(List<lookup.State> items) async {
    await _isar.writeTxn(() async {
      final models = items
          .map((item) => TicketLookupModel()
            ..key = 'estado:${item.id}'
            ..type = 'estado'
            ..backendId = item.id
            ..name = item.name
            ..updatedAt = DateTime.now())
          .toList();

      final existing = await _isar.ticketLookupModels.filter().typeEqualTo('estado').findAll();
      for (final item in existing) {
        await _isar.ticketLookupModels.delete(item.id);
      }
      await _isar.ticketLookupModels.putAll(models);
    });
  }

  @override
  Future<void> cacheImportancias(List<lookup.State> items) async {
    await _isar.writeTxn(() async {
      final models = items
          .map((item) => TicketLookupModel()
            ..key = 'importancia:${item.id}'
            ..type = 'importancia'
            ..backendId = item.id
            ..name = item.name
            ..updatedAt = DateTime.now())
          .toList();

      final existing = await _isar.ticketLookupModels.filter().typeEqualTo('importancia').findAll();
      for (final item in existing) {
        await _isar.ticketLookupModels.delete(item.id);
      }
      await _isar.ticketLookupModels.putAll(models);
    });
  }

  @override
  Future<void> cacheUrgencias(List<lookup.State> items) async {
    await _isar.writeTxn(() async {
      final models = items
          .map((item) => TicketLookupModel()
            ..key = 'urgencia:${item.id}'
            ..type = 'urgencia'
            ..backendId = item.id
            ..name = item.name
            ..updatedAt = DateTime.now())
          .toList();

      final existing = await _isar.ticketLookupModels.filter().typeEqualTo('urgencia').findAll();
      for (final item in existing) {
        await _isar.ticketLookupModels.delete(item.id);
      }
      await _isar.ticketLookupModels.putAll(models);
    });
  }
}
