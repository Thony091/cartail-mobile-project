import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../../shared/widgets/widgets.dart';
import 'modern_login_page.dart';

class ModernRegisterPage extends StatefulWidget {
  static const name = 'ModernRegisterPage';
  
  const ModernRegisterPage({super.key});

  @override
  State<ModernRegisterPage> createState() => _ModernRegisterPageState();
}

class _ModernRegisterPageState extends State<ModernRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rutController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _rutController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBarWithMenu(
        title: 'Crear Cuenta',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Título
                FadeInDown(
                  child: const Text(
                    'Únete a DriveTail',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Crea tu cuenta para acceder a todos nuestros servicios',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Formulario
                FadeInUp(
                  child: ModernCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ModernInputField(
                            // controller: _nameController,
                            label: 'Nombre Completo (*)',
                            hint: 'Ej: Juan Pérez',
                            prefixIcon: const Icon(Icons.person),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          ModernInputField(
                            // controller: _rutController,
                            label: 'RUT (*)',
                            hint: 'Ej: 12345678-9',
                            prefixIcon: const Icon(Icons.badge),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'El RUT es requerido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          ModernInputField(
                            // controller: _birthdayController,
                            label: 'Fecha de Nacimiento',
                            hint: 'DD/MM/AAAA',
                            prefixIcon: const Icon(Icons.calendar_today),
                            readOnly: true,
                            onTap: _selectBirthday,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          ModernInputField(
                            // controller: _emailController,
                            label: 'Correo Electrónico (*)',
                            hint: 'ejemplo@correo.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'El correo es requerido';
                              }
                              if (!value!.contains('@')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          ModernInputField(
                            // controller: _phoneController,
                            label: 'Número de Teléfono (*)',
                            hint: 'Ej: 987654321',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'El teléfono es requerido';
                              }
                              if (value!.length < 9) {
                                return 'Ingresa un número válido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          ModernInputField(
                            // controller: _passwordController,
                            label: 'Contraseña (*)',
                            hint: 'Mínimo 6 caracteres',
                            obscureText: _obscurePassword,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'La contraseña es requerida';
                              }
                              if (value!.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ModernButton(
                              text: 'Crear Cuenta',
                              icon: Icons.person_add,
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : _handleRegister,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿Ya tienes cuenta? ',
                                style: TextStyle(color: Color(0xFF7f8c8d)),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernLoginPage())),
                                // onTap: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Inicia sesión',
                                  style: TextStyle(
                                    color: Color(0xFF3498db),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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

  void _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 años atrás
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _birthdayController.text = '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      // Simular registro
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar éxito y navegar
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
                Icons.check_circle,
                color: Color(0xFF27ae60),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Cuenta Creada!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu cuenta ha sido creada exitosamente. Ahora puedes iniciar sesión.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7f8c8d),
              ),
            ),
          ],
        ),
        actions: [
          ModernButton(
            text: 'Continuar',
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