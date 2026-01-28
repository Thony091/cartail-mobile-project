import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/data/models/isar_domain_models.dart';
import '../../../../shared/domain/entities/state.dart' as lookup;
import 'ticket_urgencia_local_datasource.dart';

class TicketUrgenciaLocalDatasourceImpl implements TicketUrgenciaLocalDatasource {
  TicketUrgenciaLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  @override
  Future<List<lookup.State>> getAll() async {
    final models = await _isar.ticketUrgenciaModels.where().sortByName().findAll();
    return models
        .map((m) => lookup.State(id: m.backendId, name: m.name))
        .toList();
  }

  @override
  Future<void> cacheAll(List<lookup.State> items) async {
    await _isar.writeTxn(() async {
      final models = items
          .map((item) => TicketUrgenciaModel()
            ..backendId = item.id
            ..name = item.name
            ..updatedAt = DateTime.now())
          .toList();
      await _isar.ticketUrgenciaModels.clear();
      await _isar.ticketUrgenciaModels.putAll(models);
    });
  }
}
