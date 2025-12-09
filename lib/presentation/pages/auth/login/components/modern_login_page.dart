
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:portafolio_project/presentation/pages/auth/login/components/login_form.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_card.dart';

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
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo y título
                FadeInDown(
                  child: Column(
                    children: [
                      Container(
                        // alignment: Alignment.center,
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset(
                          'assets/logo/logo-prime-no-bg.png',
                          width: 190, 
                          height: 190, 
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Text(
                        'Tu centro automotriz de confianza',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                // Formulario de login
                FadeInUp(
                  child: const ModernCard(
                    child: LoginForm(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
