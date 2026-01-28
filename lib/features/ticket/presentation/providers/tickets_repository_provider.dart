import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../data/datasources/ticket_datasource_impl.dart';
import '../../data/repositories/ticket_repository_remote_impl.dart';
import '../../domain/repositories/ticket_repository.dart';

/// Provider del repositorio de tickets (remote-only).
final ticketsRepositoryProvider = Provider<TicketRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';

  return TicketRepositoryRemoteImpl(
    remoteDatasource: TicketDatasourceImpl(accessToken: accessToken),
  );
});
