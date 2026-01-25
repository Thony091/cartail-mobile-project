import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../data/datasources/client_datasource_impl.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/repositories/client_repository.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';

  final clientRepository = ClientRepositoryImpl(
    ClientDatasourceImpl(accessToken: accessToken),
  );

  return clientRepository;
});
