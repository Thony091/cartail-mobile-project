import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'conflict_resolution_service.dart';

/// Provider for conflict resolution service
final conflictResolutionServiceProvider = Provider<ConflictResolutionService>((ref) {
  return const ConflictResolutionServiceImpl();
});

/// Provider for storing the active conflict resolution strategy
/// Can be overridden per entity type or feature
final conflictResolutionStrategyProvider = Provider<ConflictResolutionStrategy>((ref) {
  // Default to last-write-wins for most cases
  // Override this provider in specific features for custom behavior
  return ConflictResolutionStrategy.lastWriteWins;
});
