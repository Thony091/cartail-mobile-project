import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/models/admin_response_models.dart';
import '../../../auth/data/datasources/admin_auth_datasource.dart';
import '../../../auth/presentation/providers/admin_auth_provider.dart';

class OperatorUsersState {
  final bool isLoading;
  final bool hasLoaded;
  final List<AdminUserModel> operators;
  final String? errorMessage;

  const OperatorUsersState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.operators = const [],
    this.errorMessage,
  });

  OperatorUsersState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    List<AdminUserModel>? operators,
    String? errorMessage,
  }) {
    return OperatorUsersState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      operators: operators ?? this.operators,
      errorMessage: errorMessage,
    );
  }
}

class OperatorUsersNotifier extends StateNotifier<OperatorUsersState> {
  final AdminAuthDatasource _datasource;

  OperatorUsersNotifier(this._datasource)
      : super(const OperatorUsersState());

  Future<void> loadOperators({bool force = false}) async {
    if (state.isLoading) return;
    if (state.hasLoaded && !force) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _datasource.listUsers(
        limit: 100,
        offset: 0,
        filterField: 'role',
        filterOperator: 'eq',
        filterValue: 'operator',
      );

      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        operators: response.users,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final operatorUsersProvider =
    StateNotifierProvider<OperatorUsersNotifier, OperatorUsersState>((ref) {
  final datasource = ref.watch(adminAuthDatasourceProvider);
  return OperatorUsersNotifier(datasource);
});
