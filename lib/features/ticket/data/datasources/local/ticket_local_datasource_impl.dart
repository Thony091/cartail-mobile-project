import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/data/models/isar_domain_models.dart';
import 'ticket_local_datasource.dart';

class TicketLocalDatasourceImpl implements TicketLocalDatasource {
  TicketLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  @override
  Future<TicketModel?> getByBackendId(String backendId) {
    return _isar.ticketModels.filter().backendIdEqualTo(backendId).findFirst();
  }

  @override
  Future<List<TicketModel>> getByReservationId(String reservationId) {
    return _isar.ticketModels
        .filter()
        .reservationIdEqualTo(reservationId)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  @override
  Future<List<TicketModel>> getAll() {
    return _isar.ticketModels.where().sortByUpdatedAtDesc().findAll();
  }

  @override
  Future<List<TicketModel>> getUnsynced() {
    return _isar.ticketModels.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<void> upsert(TicketModel model) async {
    await _isar.writeTxn(() async {
      await _isar.ticketModels.put(model);
      if (model.reservation.value != null) {
        await model.reservation.save();
      }
      if (model.service.value != null) {
        await model.service.save();
      }
      if (model.user.value != null) {
        await model.user.save();
      }
    });
  }

  @override
  Future<void> deleteByBackendId(String backendId) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.ticketModels
          .filter()
          .backendIdEqualTo(backendId)
          .findFirst();
      if (existing == null) return;
      await _isar.ticketModels.delete(existing.id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.ticketModels.clear();
    });
  }
}
