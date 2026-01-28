import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/services.dart';
import 'services_repository_provider.dart';

/// Obtiene todos los servicios.
final getAllServicesProvider = FutureProvider<List<Services>>((ref) async {
  final repository = ref.watch(servicesRepositoryProvider);
  return repository.getServices();
});

/// Crea un nuevo servicio.
final createServiceProvider =
    FutureProvider.family<Services, ServicePayload>((ref, payload) async {
  final repository = ref.watch(servicesRepositoryProvider);
  return repository.createUpdateService(payload.data);
});

/// Actualiza un servicio existente.
final updateServiceProvider =
    FutureProvider.family<Services, ServiceUpdatePayload>((ref, payload) async {
  final repository = ref.watch(servicesRepositoryProvider);
  final data = Map<String, dynamic>.from(payload.data)..['id'] = payload.serviceId;
  return repository.createUpdateService(data);
});

class ServicePayload {
  final Map<String, dynamic> data;

  const ServicePayload(this.data);
}

class ServiceUpdatePayload {
  final String serviceId;
  final Map<String, dynamic> data;

  const ServiceUpdatePayload({
    required this.serviceId,
    required this.data,
  });
}
