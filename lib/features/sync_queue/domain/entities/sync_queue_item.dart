import 'package:uuid/uuid.dart';

enum SyncActionType { create, update, delete }

enum SyncEntityType {
  user,
  reservation,
  ticket,
  service,
  vehicle,
  realizedWork,
  slot,
  message,
  invoice,
}

enum SyncStatus { pending, processing, synced, failed }

class SyncQueueItem {
  final String syncId;
  final SyncActionType action;
  final SyncEntityType entity;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final SyncStatus status;
  final DateTime? lastTriedAt;

  SyncQueueItem({
    required this.syncId,
    required this.action,
    required this.entity,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
    required this.status,
    this.lastError,
    this.lastTriedAt,
  });

  factory SyncQueueItem.newItem({
    required SyncActionType action,
    required SyncEntityType entity,
    required Map<String, dynamic> payload,
  }) {
    return SyncQueueItem(
      syncId: const Uuid().v4(),
      action: action,
      entity: entity,
      payload: payload,
      createdAt: DateTime.now(),
      retryCount: 0,
      status: SyncStatus.pending,
      lastError: null,
      lastTriedAt: null,
    );
  }

  SyncQueueItem copyWith({
    int? retryCount,
    String? lastError,
    SyncStatus? status,
    DateTime? lastTriedAt,
  }) {
    return SyncQueueItem(
      syncId: syncId,
      action: action,
      entity: entity,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      lastTriedAt: lastTriedAt ?? this.lastTriedAt,
    );
  }
}
