import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/better_auth_provider.dart';
import '../../features/user/domain/entities/user_role.dart';
import '../../presentation/presentation_container.dart';

final goRouterNotifierProvider = Provider<GoRouterNotifier>((ref) {
  final notifier = GoRouterNotifier();

  final initialAuthState = ref.read(betterAuthProvider);
  notifier.updateFromAuth(initialAuthState);

  ref.listen<BetterAuthState>(betterAuthProvider, (previous, next) {
    notifier.updateFromAuth(next);
  });

  return notifier;
});

class GoRouterNotifier extends ChangeNotifier {
  AuthStatus _authStatus = AuthStatus.checking;
  UserRole _userRole = UserRole.guest;

  AuthStatus get authStatus => _authStatus;

  /// Obtiene el rol del usuario actual
  UserRole get userRole => _userRole;

  void updateFromAuth(BetterAuthState state) {
    final nextStatus = _mapStatus(state.status);
    final nextRole = state.userRole;

    if (_authStatus == nextStatus && _userRole == nextRole) return;

    _authStatus = nextStatus;
    _userRole = nextRole;
    notifyListeners();
  }

  AuthStatus _mapStatus(BetterAuthStatus status) {
    switch (status) {
      case BetterAuthStatus.initial:
        return AuthStatus.checking;
      case BetterAuthStatus.loading:
        // Durante loading (login/register), mantener el estado anterior
        // para no causar redirecciones innecesarias
        return _authStatus;
      case BetterAuthStatus.authenticated:
        return AuthStatus.authenticated;
      case BetterAuthStatus.unauthenticated:
        return AuthStatus.notAuthenticated;
      case BetterAuthStatus.error:
        return AuthStatus.notAuthenticated;
    }
  }
}
