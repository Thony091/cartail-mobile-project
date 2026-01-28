import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/user_datasource_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';

/// Provider del repositorio de usuarios (remote-only).
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remoteDatasource: UserDatasourceImpl(),
  );
});
