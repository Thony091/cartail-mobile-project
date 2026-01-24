import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_scaffold_with_drawer.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import 'modern_edit_profile_widgets.dart';

class ModernEditProfilePage extends ConsumerStatefulWidget {
  static const name = 'ModernEditProfilePage';

  const ModernEditProfilePage({super.key});

  @override
  ModernEditProfilePageState createState() => ModernEditProfilePageState();
}

class ModernEditProfilePageState extends ConsumerState<ModernEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rutController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = ref.read(betterAuthProvider).user;
    if (authState == null) {
      _nameController.text = '';
      _rutController.text = '';
      _birthdayController.text = '';
      _phoneController.text = '';
      _bioController.text = '';
      return;
    }
    // Cargar datos actuales del usuario
    _nameController.text = authState.name ?? '';
    _rutController.text = authState.rut ?? '';
    _birthdayController.text = authState.birthday ?? '';
    _phoneController.text = authState.phone ?? '';
    _bioController.text = authState.bio ?? '';
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

  void _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 años atrás
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
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
      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SuccesUpdateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernScaffoldWithDrawer(
      title: 'Editar Perfil',
      // automaticallyImplyLeading: true,
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
                EditProfileAvatarSection(onChangeAvatar: _changeAvatar),

                const SizedBox(height: 24),

                // Información personal
                EditProfileInfoSection(
                  nameController: _nameController,
                  rutController: _rutController,
                  birthdayController: _birthdayController,
                  phoneController: _phoneController,
                  bioController: _bioController,
                  onSelectBirthday: _selectBirthday,
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
      builder: (context) => const AvatarSelectionSheet(),
    );
  }

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

      if (mounted) {
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
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }
}
