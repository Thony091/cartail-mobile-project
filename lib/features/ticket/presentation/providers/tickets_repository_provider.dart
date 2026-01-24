import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/presentation_container.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../data/datasources/ticket_datasource_impl.dart';
import '../../data/repositories/ticket_repository_impl.dart';
import '../../domain/repositories/ticket_repository.dart';

final ticketsRepositoryProvider = Provider<TicketRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';

  final ticketsRepository = TicketRepositoryImpl(
    TicketDatasourceImpl(accessToken: accessToken),
  );

  return ticketsRepository;
});
