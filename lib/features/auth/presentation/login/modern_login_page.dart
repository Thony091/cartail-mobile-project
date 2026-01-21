import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:portafolio_project/features/auth/presentation/login/components/login_form.dart';
import 'package:portafolio_project/features/shared/presentation/shared/widgets/modern_card.dart';

import 'modern_login_widgets.dart';

class ModernLoginPage extends StatelessWidget {
  static const name = 'ModernLoginPage';

  const ModernLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo y título
                FadeInDown(child: const AuthLogo()),
                const SizedBox(height: 40),
                // Formulario de login
                FadeInUp(child: const ModernCard(child: LoginForm())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
