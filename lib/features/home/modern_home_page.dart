import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/home/views/admin_body_home_view.dart';
import 'package:portafolio_project/features/home/views/operator_body_home_view.dart';
import 'package:portafolio_project/features/home/views/user_body_home_view.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'package:portafolio_project/features/auth/presentation/providers/auth_provider.dart';

class ModernHomePage extends ConsumerStatefulWidget {
  static const name = 'ModernHomePage';

  const ModernHomePage({super.key});

  @override
  ModernHomePageState createState() => ModernHomePageState();
}

class ModernHomePageState extends ConsumerState<ModernHomePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(betterAuthProvider);

    return PopScope(
      canPop: false,
      child: ModernScaffoldWithDrawer(
        title: authState.isAuthenticated
            ? 'Hola ${authState.session!.user.name}'
            : 'Bienvenido',
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF667eea).withValues(alpha: .1),
                const Color(0xFFf8fafc),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (authState.isAuthenticated)
                  authState.isAdmin
                      ? const AdminBodyHomeView()
                      : authState.isOperator
                          ? const OperatorBodyHomeView()
                          : const UserBodyHomeView()
                else
                  const UserBodyHomeView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
