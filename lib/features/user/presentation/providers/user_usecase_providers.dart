import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/better_auth_provider.dart';
import '../../domain/entities/user.dart';
import 'user_repository_provider.dart';

/// Obtiene el usuario actual desde el repositorio.
final getCurrentUserProvider = FutureProvider<User?>((ref) async {
  final authState = ref.watch(betterAuthProvider);
  final authUser = authState.user;
  if (authUser == null) return null;

  final repository = ref.watch(userRepositoryProvider);
  return repository.getUser('users', authUser.id);
});

/// Actualiza el perfil del usuario actual.
final updateUserProfileProvider =
    FutureProvider.family<User, UserProfileUpdateInput>((ref, input) async {
  final authState = ref.watch(betterAuthProvider);
  final authUser = authState.user;
  final userId = input.userId ?? authUser?.id;
  if (userId == null || userId.isEmpty) {
    throw StateError('No user session available');
  }

  final repository = ref.watch(userRepositoryProvider);
  return repository.updateUser(input.data, userId);
});

class UserProfileUpdateInput {
  final Map<String, dynamic> data;
  final String? userId;

  const UserProfileUpdateInput({
    required this.data,
    this.userId,
  });
}
