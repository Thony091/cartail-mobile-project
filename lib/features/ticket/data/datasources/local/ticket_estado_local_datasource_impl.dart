import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/data/models/isar_domain_models.dart';
import '../../../../shared/domain/entities/state.dart' as lookup;
import 'ticket_estado_local_datasource.dart';

class TicketEstadoLocalDatasourceImpl implements TicketEstadoLocalDatasource {
  TicketEstadoLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  @override
  Future<List<lookup.State>> getAll() async {
    final models = await _isar.ticketEstadoModels.where().sortByName().findAll();
    return models
        .map((m) => lookup.State(id: m.backendId, name: m.name))
        .toList();
  }

  @override
  Future<void> cacheAll(List<lookup.State> items) async {
    await _isar.writeTxn(() async {
      final models = items
          .map((item) => TicketEstadoModel()
            ..backendId = item.id
            ..name = item.name
            ..updatedAt = DateTime.now())
          .toList();
      await _isar.ticketEstadoModels.clear();
      await _isar.ticketEstadoModels.putAll(models);
    });
  }
}
