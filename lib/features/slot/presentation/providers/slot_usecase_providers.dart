import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/slot.dart';
import 'slot_repository_provider.dart';

/// Obtiene slots por servicio.
final getSlotsByServiceProvider =
    FutureProvider.family<List<Slot>, String>((ref, serviceBackendId) async {
  final repository = ref.watch(slotRepositoryProvider);
  return repository.getSlotsByService(serviceBackendId);
});

/// Fuerza refresh de slots por servicio.
final refreshSlotsForServiceProvider =
    FutureProvider.family<List<Slot>, String>((ref, serviceBackendId) async {
  return ref.refresh(getSlotsByServiceProvider(serviceBackendId).future);
});
