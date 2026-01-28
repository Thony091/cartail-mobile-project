import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/data/models/isar_domain_models.dart';
import 'reservation_local_datasource.dart';

class ReservationLocalDatasourceImpl implements ReservationLocalDatasource {
  ReservationLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  @override
  Future<ReservationModel?> getByBackendId(String backendId) {
    return _isar.reservationModels
        .filter()
        .backendIdEqualTo(backendId)
        .findFirst();
  }

  @override
  Future<List<ReservationModel>> getByDate(String reservationDate) {
    return _isar.reservationModels
        .filter()
        .reservationDateEqualTo(reservationDate)
        .sortByReservationTime()
        .findAll();
  }

  @override
  Future<List<ReservationModel>> getAll() {
    return _isar.reservationModels.where().sortByUpdatedAtDesc().findAll();
  }

  @override
  Future<List<ReservationModel>> getUnsynced() {
    return _isar.reservationModels.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<List<ReservationModel>> getUpdatedAfter(DateTime since) {
    return _isar.reservationModels
        .filter()
        .updatedAtGreaterThan(since)
        .findAll();
  }

  @override
  Future<void> upsert(ReservationModel model) async {
    await _isar.writeTxn(() async {
      await _isar.reservationModels.put(model);
      if (model.user.value != null) {
        await model.user.save();
      }
      if (model.service.value != null) {
        await model.service.save();
      }
      if (model.vehicle.value != null) {
        await model.vehicle.save();
      }
      if (model.slot.value != null) {
        await model.slot.save();
      }
    });
  }

  @override
  Future<void> deleteByBackendId(String backendId) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.reservationModels
          .filter()
          .backendIdEqualTo(backendId)
          .findFirst();
      if (existing == null) return;
      await _isar.reservationModels.delete(existing.id);
    });
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.reservationModels.clear();
    });
  }
}
