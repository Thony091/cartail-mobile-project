import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../data/datasources/slot_datasource_impl.dart';
import '../../data/repositories/slot_repository_impl.dart';
import '../../domain/repositories/slot_repository.dart';

/// Provider del repositorio de slots (remote-only).
final slotRepositoryProvider = Provider<SlotRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';

  return SlotRepositoryImpl(
    remoteDatasource: SlotDatasourceImpl(accessToken: accessToken),
  );
});
