/// Detects and resolves conflicts when offline changes conflict with remote updates
///
/// Conflict scenarios:
/// 1. Entity deleted locally, updated remotely → Keep remote
/// 2. Entity updated locally, deleted remotely → Keep local
/// 3. Both updated with different values → Use resolution strategy
/// 4. Same version, same update time → No conflict
///
abstract class ConflictResolutionService {
  /// Detects if there's a conflict between local and remote versions
  Future<bool> hasConflict({
    required String entityId,
    required DateTime localUpdatedAt,
    required DateTime remoteUpdatedAt,
    required dynamic localData,
    required dynamic remoteData,
  });

  /// Resolves a conflict using the specified strategy
  Future<dynamic> resolve({
    required String entityId,
    required dynamic localData,
    required dynamic remoteData,
    required ConflictResolutionStrategy strategy,
  });
}

/// Strategies for resolving conflicts
enum ConflictResolutionStrategy {
  /// Keep the most recently updated version
  lastWriteWins,

  /// Keep the local (offline) version
  localWins,

  /// Keep the remote version
  remoteWins,

  /// Merge both versions (requires custom logic)
  merge,
}

/// Default conflict resolution implementation
class ConflictResolutionServiceImpl implements ConflictResolutionService {
  const ConflictResolutionServiceImpl();

  @override
  Future<bool> hasConflict({
    required String entityId,
    required DateTime localUpdatedAt,
    required DateTime remoteUpdatedAt,
    required dynamic localData,
    required dynamic remoteData,
  }) async {
    // No conflict if same version
    if (localUpdatedAt == remoteUpdatedAt) {
      return false;
    }

    // Conflict if both were modified
    return true;
  }

  @override
  Future<dynamic> resolve({
    required String entityId,
    required dynamic localData,
    required dynamic remoteData,
    required ConflictResolutionStrategy strategy,
  }) async {
    switch (strategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        // Determined by timestamp (handled by caller)
        return remoteData;

      case ConflictResolutionStrategy.localWins:
        return localData;

      case ConflictResolutionStrategy.remoteWins:
        return remoteData;

      case ConflictResolutionStrategy.merge:
        // Basic merge: overlay local changes on remote
        if (localData is Map && remoteData is Map) {
          return {...remoteData, ...localData};
        }
        // For non-map types, use remoteWins
        return remoteData;
    }
  }
}

/// Represents a detected conflict
class DataConflict {
  final String entityId;
  final String entityType;
  final dynamic localData;
  final dynamic remoteData;
  final DateTime localUpdatedAt;
  final DateTime remoteUpdatedAt;
  final DateTime detectedAt;

  const DataConflict({
    required this.entityId,
    required this.entityType,
    required this.localData,
    required this.remoteData,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
    required this.detectedAt,
  });

  bool get remoteIsNewer => remoteUpdatedAt.isAfter(localUpdatedAt);
  bool get localIsNewer => localUpdatedAt.isAfter(remoteUpdatedAt);
}
