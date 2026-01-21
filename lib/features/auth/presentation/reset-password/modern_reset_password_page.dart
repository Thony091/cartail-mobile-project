import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../shared/presentation/shared/widgets/widgets.dart';
import 'modern_reset_password_widgets.dart';

class ModernResetPasswordPage extends StatelessWidget {
  static const name = 'ModernResetPasswordPage';

  const ModernResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBarWithMenu(
        title: 'Recuperar Contraseña',
        automaticallyImplyLeading: true,
      ),
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
                const SizedBox(height: 40),

                // Icono y título
                FadeInDown(child: const ResetPasswordHeader()),

                const SizedBox(height: 50),

                // Formulario
                FadeInUp(child: const ResetPasswordForm()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
