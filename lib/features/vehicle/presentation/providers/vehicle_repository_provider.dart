import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../data/datasources/vehicle_datasource_impl.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/repositories/vehicle_repository.dart';

/// Provider del repositorio de vehículos (remote-only).
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';

  return VehicleRepositoryImpl(
    remoteDatasource: VehicleDatasourceImpl(accessToken: accessToken),
  );
});
