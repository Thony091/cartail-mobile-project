import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/data/models/isar_domain_models.dart';
import '../../../../shared/domain/entities/state.dart' as lookup;
import 'ticket_importancia_local_datasource.dart';

class TicketImportanciaLocalDatasourceImpl
    implements TicketImportanciaLocalDatasource {
  TicketImportanciaLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  @override
  Future<List<lookup.State>> getAll() async {
    final models =
        await _isar.ticketImportanciaModels.where().sortByName().findAll();
    return models
        .map((m) => lookup.State(id: m.backendId, name: m.name))
        .toList();
  }

  @override
  Future<void> cacheAll(List<lookup.State> items) async {
    await _isar.writeTxn(() async {
      final models = items
          .map((item) => TicketImportanciaModel()
            ..backendId = item.id
            ..name = item.name
            ..updatedAt = DateTime.now())
          .toList();
      await _isar.ticketImportanciaModels.clear();
      await _isar.ticketImportanciaModels.putAll(models);
    });
  }
}
