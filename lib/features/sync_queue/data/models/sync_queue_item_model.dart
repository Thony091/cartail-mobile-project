import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../../domain/entities/sync_queue_item.dart';

part 'sync_queue_item_model.g.dart';

@Collection()
class SyncQueueItemModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String syncId;

  late String action;
  late String entity;
  late String payloadJson;
  late DateTime createdAt;
  late int retryCount;
  String? lastError;
  late String status;
  DateTime? lastTriedAt;

  SyncQueueItemModel();

  factory SyncQueueItemModel.fromEntity(SyncQueueItem item) {
    return SyncQueueItemModel()
      ..syncId = item.syncId
      ..action = item.action.name
      ..entity = item.entity.name
      ..payloadJson = jsonEncode(item.payload)
      ..createdAt = item.createdAt
      ..retryCount = item.retryCount
      ..lastError = item.lastError
      ..status = item.status.name
      ..lastTriedAt = item.lastTriedAt;
  }

  SyncQueueItem toEntity() {
    return SyncQueueItem(
      syncId: syncId,
      action: SyncActionType.values.firstWhere((e) => e.name == action),
      entity: SyncEntityType.values.firstWhere((e) => e.name == entity),
      payload: jsonDecode(payloadJson) as Map<String, dynamic>,
      createdAt: createdAt,
      retryCount: retryCount,
      lastError: lastError,
      status: SyncStatus.values.firstWhere((e) => e.name == status),
      lastTriedAt: lastTriedAt,
    );
  }
}
