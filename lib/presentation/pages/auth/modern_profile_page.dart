import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_edit_profile.dart';

import '../../presentation_container.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernProfilePage extends ConsumerStatefulWidget {
  static const name = 'ModernProfilePage';
  
  const ModernProfilePage({super.key});

  @override
  ModernProfilePageState createState() => ModernProfilePageState();
}

class ModernProfilePageState extends ConsumerState<ModernProfilePage> {
  @override
  Widget build(BuildContext context) {
    // final authState = ref.watch(authProvider);
    // Simulamos datos del usuario
    final UserData userData = UserData(
      name: 'Admin Test',
      email: 'admin@test.com',
      phone: '986783045',
      rut: '11111111-1',
      bio: 'Administrador del sistema DriveTail',
      isAdmin: true,
      avatar: '',
    );

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
                child: _buildProfileHeader(userData),
              ),
              
              const SizedBox(height: 32),
              
              // Información personal
              FadeInLeft(
                child: _buildPersonalInfo(userData),
              ),
              
              const SizedBox(height: 24),
              
              // Estadísticas (solo para admin)
              if (userData.isAdmin) ...[
                FadeInRight(
                  child: _buildAdminStats(),
                ),
                const SizedBox(height: 24),
              ],
              
              // Configuración
              FadeInUp(
                child: _buildSettingsSection(),
              ),
              
              const SizedBox(height: 24),
              
              // Acciones
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildActionsSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserData userData) {
    return ModernCard(
      child: Column(
        children: [
          // Avatar
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
                child: userData.avatar.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          userData.avatar,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        userData.isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
              ),
              
              // Botón editar avatar
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
          
          // Nombre y rol
          Text(
            userData.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: userData.isAdmin 
                  ? const Color(0xFFf39c12).withOpacity(0.1)
                  : const Color(0xFF3498db).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userData.isAdmin ? 'Administrador' : 'Usuario',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: userData.isAdmin 
                    ? const Color(0xFFf39c12)
                    : const Color(0xFF3498db),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón editar perfil
          ModernButton(
            text: 'Editar Perfil',
            style: ModernButtonStyle.secondary,
            icon: Icons.edit,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernEditProfilePage()));
              // Navegar a editar perfil
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(UserData userData) {
    return ModernCard(
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
          
          _buildInfoItem(Icons.email, 'Correo Electrónico', userData.email),
          _buildInfoItem(Icons.phone, 'Teléfono', userData.phone),
          _buildInfoItem(Icons.badge, 'RUT', userData.rut),
          
          if (userData.bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoItem(Icons.info, 'Biografía', userData.bio, maxLines: 3),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3498db),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2c3e50),
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminStats() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Servicios', '24', const Color(0xFF3498db)),
              ),
              Expanded(
                child: _buildStatItem('Trabajos', '156', const Color(0xFF27ae60)),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Reservas', '89', const Color(0xFFf39c12)),
              ),
              Expanded(
                child: _buildStatItem('Mensajes', '12', const Color(0xFFe74c3c)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingItem(
            Icons.notifications,
            'Notificaciones',
            'Gestionar notificaciones push',
            () {},
          ),
          
          _buildSettingItem(
            Icons.security,
            'Privacidad y Seguridad',
            'Configurar seguridad de la cuenta',
            () {},
          ),
          
          _buildSettingItem(
            Icons.language,
            'Idioma',
            'Español (Chile)',
            () {},
          ),
          
          _buildSettingItem(
            Icons.dark_mode,
            'Tema',
            'Claro',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF7f8c8d).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF7f8c8d),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2c3e50),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF7f8c8d),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF7f8c8d),
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ModernButton(
            text: 'Cambiar Contraseña',
            style: ModernButtonStyle.secondary,
            icon: Icons.lock,
            onPressed: () {
              // Cambiar contraseña
            },
          ),
        ),
        
      ],
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

  // void _showLogoutConfirmation() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Cerrar Sesión'),
  //       content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('Cancelar'),
  //         ),
  //         ModernButton(
  //           text: 'Cerrar Sesión',
  //           style: ModernButtonStyle.danger,
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             // Logout logic
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
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