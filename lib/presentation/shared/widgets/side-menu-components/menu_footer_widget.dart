import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/providers/auth_provider.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_button.dart';

class MenuFooterWidget extends ConsumerWidget {

  final bool isAuthenticated;

  const MenuFooterWidget({
    super.key,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFe2e8f0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (!isAuthenticated) ...[
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Iniciar Sesión',
                style: ModernButtonStyle.primary,
                icon: Icons.login,
                onPressed: () => context.push('/login'),
                // onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernLoginPage())),
                // onPressed: () => _navigateTo(context, '/login'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Registrarse',
                style: ModernButtonStyle.secondary,
                icon: Icons.person_add,
                onPressed: () => context.push('/register'),
                // onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernRegisterPage())),
                // onPressed: () => _navigateTo(context, '/register'),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Cerrar Sesión',
                style: ModernButtonStyle.danger,
                icon: Icons.logout,
                onPressed: () => ref.read( authProvider.notifier ).logOut(),
                // onPressed: () => _handleLogout(),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Información de la app
          const Text(
            'DriveTail v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
      ),
    );
  }
}