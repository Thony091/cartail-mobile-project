import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../data/datasources/reservation_datasource_impl.dart';
import '../../data/repositories/reservation_repository_impl.dart';
import '../../domain/repositories/reservation_repository.dart';

/// Provider del repositorio de reservas (remote-only).
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';

  return ReservationRepositoryImpl(
    remoteDatasource: ReservationDatasourceImpl(accessToken: accessToken),
  );
});
