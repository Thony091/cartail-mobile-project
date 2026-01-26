import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import 'package:portafolio_project/features/user/domain/entities/user_role.dart';

import 'package:portafolio_project/features/user/presentation/profile/modern_profile_widgets.dart';

import '../../../../presentation/presentation_container.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../domain/entities/user.dart';
import 'modern_edit_profile_widgets.dart';

class ModernProfilePage extends ConsumerStatefulWidget {
  static const name = 'ModernProfilePage';

  const ModernProfilePage({super.key});

  @override
  ModernProfilePageState createState() => ModernProfilePageState();
}

class ModernProfilePageState extends ConsumerState<ModernProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(betterAuthProvider);
    final profileUser = _mapAuthUser(authState);

    return SafeArea(
      top: false,
      child: ModernScaffoldWithDrawer(
        title: 'Mi Perfil',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header del perfil
                FadeInDown(
                  child: ProfileHeader(
                    user: profileUser,
                    onChangeAvatar: _changeAvatar,
                  ),
                ),
                const SizedBox(height: 32),
                // Información personal
                FadeInLeft(child: PersonalInfoSection(user: profileUser)),
                const SizedBox(height: 24),
                // Estadísticas (solo para admin)
                if (profileUser.role == UserRole.admin) ...[
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
                      showDialog(
                        context: context,
                        builder: (_) => const ChangePasswordDialog(),
                      );
                    },
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

  User _mapAuthUser(BetterAuthState authState) {
    final authUser = authState.user;
    return User(
      uid: authUser?.id ?? '',
      nombre: authUser?.name ?? 'Invitado',
      rut: authUser?.rut ?? '',
      fechaNacimiento: authUser?.birthday ?? '',
      email: authUser?.email ?? '',
      telefono: authUser?.phone ?? '',
      direccion: authUser?.address ?? '',
      password: '',
      imagenPerfil: authUser?.image ?? '',
      bio: authUser?.bio ?? '',
      role: authUser?.role ?? UserRole.guest,
      isAdmin: authUser?.role == UserRole.admin,
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
