import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/better_auth_provider.dart';
import '../../../home/views/operator_body_home_view.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';

/// Página principal del operador con acceso directo a sus funcionalidades
class OperatorHomePage extends ConsumerWidget {
  static const name = 'OperatorHomePage';

  const OperatorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(betterAuthProvider);
    final title = authState.isAuthenticated
        ? 'Hola ${authState.session?.user.name ?? 'Operario'}'
        : 'Operario';

    return ModernScaffoldWithDrawer(
      title: title,
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
        child: const SingleChildScrollView(
          child: OperatorBodyHomeView(),
        ),
      ),
    );
  }
}
