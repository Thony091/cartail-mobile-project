import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:portafolio_project/domain/entities/user_role.dart';

import 'package:portafolio_project/presentation/pages/auth/profile/modern_profile_widgets.dart';

import '../../../presentation_container.dart';
import '../modern_scaffold_with_drawer.dart';

class ModernProfilePage extends ConsumerStatefulWidget {
  static const name = 'ModernProfilePage';

  const ModernProfilePage({super.key});

  @override
  ModernProfilePageState createState() => ModernProfilePageState();
}

class ModernProfilePageState extends ConsumerState<ModernProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).userData!;

    return ModernScaffoldWithDrawer(
      title: 'Mi Perfil',
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
          child: Column(
            children: [
              // Header del perfil
              FadeInDown(
                child: ProfileHeader(
                  user: authState,
                  onChangeAvatar: _changeAvatar,
                ),
              ),

              const SizedBox(height: 32),

              // Información personal
              FadeInLeft(child: PersonalInfoSection(user: authState)),

              const SizedBox(height: 24),

              // Estadísticas (solo para admin)
              if (authState.role == UserRole.admin) ...[
                FadeInRight(child: const AdminStatsSection()),
                const SizedBox(height: 24),
              ],

              // Configuración
              FadeInUp(child: const SettingsSection()),

              const SizedBox(height: 24),

              // Acciones
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: ActionsSection(
                  onChangePassword: () {
                    // Cambiar contraseña logic
                  },
                ),
              ),
            ],
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
              'Cambiar Avatar',
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
                // Tomar foto
              },
            ),

            const SizedBox(height: 12),

            ModernButton(
              text: 'Seleccionar de Galería',
              style: ModernButtonStyle.secondary,
              icon: Icons.photo_library,
              onPressed: () {
                Navigator.of(context).pop();
                // Seleccionar de galería
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserData {
  final String name;
  final String email;
  final String phone;
  final String rut;
  final String bio;
  final bool isAdmin;
  final String avatar;

  UserData({
    required this.name,
    required this.email,
    required this.phone,
    required this.rut,
    required this.bio,
    required this.isAdmin,
    required this.avatar,
  });
}
