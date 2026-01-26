import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_auth_datasource.dart';
import '../../data/models/admin_response_models.dart';
import 'admin_auth_provider.dart';

class UsersState {
  final bool isLoading;
  final bool hasLoaded;
  final List<AdminUserModel> users;
  final String? errorMessage;

  const UsersState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.users = const [],
    this.errorMessage,
  });

  UsersState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    List<AdminUserModel>? users,
    String? errorMessage,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }
}

class UsersNotifier extends StateNotifier<UsersState> {
  final AdminAuthDatasource _datasource;

  UsersNotifier(this._datasource) : super(const UsersState());

  Future<void> loadUsers({bool force = false}) async {
    if (state.isLoading) return;
    if (state.hasLoaded && !force) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _datasource.listUsers(
        limit: 200,
        offset: 0,
      );

      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        users: response.users,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final datasource = ref.watch(adminAuthDatasourceProvider);
  return UsersNotifier(datasource);
});

final usersByIdProvider = Provider<Map<String, AdminUserModel>>((ref) {
  final state = ref.watch(usersProvider);
  return {for (final user in state.users) user.id: user};
});

final operariosProvider = Provider<List<AdminUserModel>>((ref) {
  final state = ref.watch(usersProvider);
  return state.users.where((user) {
    final role = user.role?.toLowerCase();
    return role == 'operario' || role == 'operator';
  }).toList();
});
