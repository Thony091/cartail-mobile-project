import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/widgets.dart';

class ModernResetPasswordPage extends StatefulWidget {
  static const name = 'ModernResetPasswordPage';
  
  const ModernResetPasswordPage({super.key});

  @override
  State<ModernResetPasswordPage> createState() => _ModernResetPasswordPageState();
}

class _ModernResetPasswordPageState extends State<ModernResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBarWithMenu(
        title: 'Recuperar Contraseña',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Icono y título
                FadeInDown(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2c3e50),
                              const Color(0xFF34495e),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No te preocupes, te ayudamos a recuperarla',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Formulario
                FadeInUp(
                  child: ModernCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recuperar Contraseña',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2c3e50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ingresa tu correo electrónico y te enviaremos instrucciones para restablecer tu contraseña.',
                            style: TextStyle(
                              color: Color(0xFF7f8c8d),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          ModernInputField(
                            // controller: _emailController,
                            label: 'Correo Electrónico',
                            hint: 'ejemplo@correo.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Por favor ingresa tu correo';
                              }
                              if (!value!.contains('@')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ModernButton(
                              text: 'Enviar Instrucciones',
                              icon: Icons.send,
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : _handleResetPassword,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Volver al inicio de sesión',
                                style: TextStyle(
                                  color: Color(0xFF3498db),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      // Simular envío de email
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar éxito
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF27ae60).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.mark_email_read,
                color: Color(0xFF27ae60),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Email Enviado!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hemos enviado las instrucciones para restablecer tu contraseña a ${_emailController.text}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7f8c8d),
              ),
            ),
          ],
        ),
        actions: [
          ModernButton(
            text: 'Entendido',
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Volver a login
            },
          ),
        ],
      ),
    );
  }
}