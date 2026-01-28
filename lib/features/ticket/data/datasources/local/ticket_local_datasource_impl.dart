import 'dart:async';

import 'package:isar_community/isar.dart';

import '../../../../../config/services/storage/isar_service.dart';
import '../../../../shared/data/models/isar_domain_models.dart';
import 'ticket_local_datasource.dart';

class TicketLocalDatasourceImpl implements TicketLocalDatasource {
  TicketLocalDatasourceImpl({required IsarService isarService})
      : _isarService = isarService;

  final IsarService _isarService;
  Future<void> _writeChain = Future.value();

  Isar get _isar => _isarService.isar;

  Future<T> _enqueueWrite<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _writeChain = _writeChain.catchError((_) {}).then((_) async {
      try {
        final result = await _isar.writeTxn(action);
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

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
    await _enqueueWrite(() async {
      await _isar.ticketModels.putByIndex('backendId', model);
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
  Future<void> upsertBatch(List<TicketModel> models) async {
    await _enqueueWrite(() async {
      await _isar.ticketModels.putAllByIndex('backendId', models);
      for (final model in models) {
        if (model.reservation.value != null) {
          await model.reservation.save();
        }
        if (model.service.value != null) {
          await model.service.save();
        }
        if (model.user.value != null) {
          await model.user.save();
        }
      }
    });
  }

  @override
  Future<void> clearAndUpsertBatch(List<TicketModel> models) async {
    await _enqueueWrite(() async {
      await _isar.ticketModels.clear();
      await _isar.ticketModels.putAllByIndex('backendId', models);
      for (final model in models) {
        if (model.reservation.value != null) {
          await model.reservation.save();
        }
        if (model.service.value != null) {
          await model.service.save();
        }
        if (model.user.value != null) {
          await model.user.save();
        }
      }
    });
  }

  @override
  Future<void> deleteByBackendId(String backendId) async {
    await _enqueueWrite(() async {
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
    await _enqueueWrite(() async {
      await _isar.ticketModels.clear();
    });
  }
}
