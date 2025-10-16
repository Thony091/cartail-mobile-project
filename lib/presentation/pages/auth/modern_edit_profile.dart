import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../../shared/widgets/widgets.dart';

class ModernEditProfilePage extends StatefulWidget {
  static const name = 'ModernEditProfilePage';
  
  const ModernEditProfilePage({super.key});

  @override
  State<ModernEditProfilePage> createState() => _ModernEditProfilePageState();
}

class _ModernEditProfilePageState extends State<ModernEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rutController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
  }

  void _loadUserData() {
    // Cargar datos actuales del usuario
    _nameController.text = 'Admin Test';
    _rutController.text = '11111111-1';
    _birthdayController.text = '15/06/1990';
    _phoneController.text = '986783045';
    _bioController.text = 'Administrador del sistema DriveTail';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rutController.dispose();
    _birthdayController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _selectBirthday( ) async {
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

  void _handleRegister( ) async {
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

  void _showSuccessDialog( ) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBarWithMenu(
        title: 'Editar Perfil',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar section
                FadeInDown(
                  child: ModernCard(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [const Color(0xFF3498db), const Color(0xFF2980b9)],
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3498db).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _changeAvatar,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFf39c12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Toca el ícono para cambiar tu foto',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Información personal
                FadeInLeft(
                  child: ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información Personal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        ModernInputField(
                          // controller: _nameController,
                          label: 'Nombre Completo',
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
                          label: 'RUT',
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
                          prefixIcon: const Icon(Icons.calendar_today),
                          readOnly: true,
                          onTap: _selectBirthday,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        ModernInputField(
                          // controller: _phoneController,
                          label: 'Número de Teléfono',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'El teléfono es requerido';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        const ModernInputField(
                          // controller: _bioController,
                          label: 'Biografía',
                          hint: 'Cuéntanos algo sobre ti...',
                          maxLines: 4,
                          prefixIcon: Icon(Icons.info),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Botones de acción
                FadeInUp(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ModernButton(
                          text: 'Guardar Cambios',
                          icon: Icons.save,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _handleSave,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ModernButton(
                          text: 'Cambiar Contraseña',
                          style: ModernButtonStyle.secondary,
                          icon: Icons.lock,
                          onPressed: _showChangePasswordDialog,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
  }

  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cambiar Foto de Perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 20),
            ModernButton(
              text: 'Tomar Foto',
              icon: Icons.camera_alt,
              onPressed: () {
                Navigator.of(context).pop();
                // Implementar cámara
              },
            ),
            const SizedBox(height: 12),
            ModernButton(
              text: 'Seleccionar de Galería',
              style: ModernButtonStyle.secondary,
              icon: Icons.photo_library,
              onPressed: () {
                Navigator.of(context).pop();
                // Implementar galería
              },
            ),
          ],
        ),
      ),
    );
  }

  // void _selectBirthday() async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime(1990, 6, 15),
  //     firstDate: DateTime(1950),
  //     lastDate: DateTime.now(),
  //   );
    
  //   if (picked != null) {
  //     setState(() {
  //       _birthdayController.text = '${picked.day.toString().padLeft(2, '0')}/'
  //           '${picked.month.toString().padLeft(2, '0')}/'
  //           '${picked.year}';
  //     });
  //   }
  // }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      // Simular guardado
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFF27ae60),
        ),
      );
      
      Navigator.of(context).pop();
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModernInputField(
              // controller: currentPasswordController,
              label: 'Contraseña Actual',
              obscureText: true,
              prefixIcon: Icon(Icons.lock_outline),
            ),
           SizedBox(height: 16),
            ModernInputField(
              // controller: newPasswordController,
              label: 'Nueva Contraseña',
              obscureText: true,
              prefixIcon: Icon(Icons.lock),
            ),
           SizedBox(height: 16),
            ModernInputField(
              // controller: confirmPasswordController,
              label: 'Confirmar Contraseña',
              obscureText: true,
              prefixIcon: Icon(Icons.lock),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ModernButton(
            text: 'Cambiar',
            onPressed: () {
              // Validar y cambiar contraseña
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña cambiada correctamente'),
                  backgroundColor: Color(0xFF27ae60),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}