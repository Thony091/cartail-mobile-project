import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import '../../data/datasources/state_datasource_impl.dart';
import '../../data/repositories/state_repository_impl.dart';
import '../../domain/repositories/state_repository.dart';

final stateRepositoryProvider = Provider<StateRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token ?? '';
  return StateRepositoryImpl(StateDatasourceImpl(accessToken: accessToken));
});
