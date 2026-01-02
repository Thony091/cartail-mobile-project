import 'package:flutter/material.dart';
import 'package:portafolio_project/domain/entities/user.dart';
import 'package:portafolio_project/domain/entities/user_role.dart';
import 'package:portafolio_project/presentation/pages/auth/profile/modern_edit_profile.dart';

import '../../../presentation_container.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback onChangeAvatar;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onChangeAvatar,
  });

  @override
  Widget build(BuildContext context) {
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
                      color: const Color(0xFF3498db).withValues(alpha: .3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: user.imagenPerfil.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          user.imagenPerfil,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        user.role == UserRole.admin
                            ? Icons.admin_panel_settings
                            : user.role == UserRole.operator
                            ? Icons.person_pin
                            : Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
              ),

              // Botón editar avatar
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onChangeAvatar,
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
            user.nombre,
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
              color: user.role != UserRole.guest
                  ? const Color(0xFFf39c12).withValues(alpha: 0.1)
                  : const Color(0xFF3498db).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (user.role == UserRole.admin)
                  ? 'Administrador'
                  : (user.role == UserRole.operator)
                  ? 'Operario'
                  : 'Usuario',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: user.role != UserRole.guest
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ModernEditProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PersonalInfoSection extends StatelessWidget {
  final User user;

  const PersonalInfoSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
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

          InfoItem(
            icon: Icons.email,
            label: 'Correo Electrónico',
            value: user.email,
          ),
          InfoItem(icon: Icons.phone, label: 'Teléfono', value: user.telefono),
          InfoItem(icon: Icons.badge, label: 'RUT', value: user.rut),

          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            InfoItem(
              icon: Icons.info,
              label: 'Biografía',
              value: user.bio,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  const InfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Icon(icon, color: const Color(0xFF3498db), size: 20),
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
}

class AdminStatsSection extends StatelessWidget {
  const AdminStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: StatItem(
                  label: 'Servicios',
                  value: '24',
                  color: const Color(0xFF3498db),
                ),
              ),
              Expanded(
                child: StatItem(
                  label: 'Trabajos',
                  value: '156',
                  color: const Color(0xFF27ae60),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: StatItem(
                  label: 'Reservas',
                  value: '89',
                  color: const Color(0xFFf39c12),
                ),
              ),
              Expanded(
                child: StatItem(
                  label: 'Mensajes',
                  value: '12',
                  color: const Color(0xFFe74c3c),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
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

          SettingItem(
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Gestionar notificaciones push',
            onTap: () {},
          ),

          SettingItem(
            icon: Icons.security,
            title: 'Privacidad y Seguridad',
            subtitle: 'Configurar seguridad de la cuenta',
            onTap: () {},
          ),

          SettingItem(
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Español (Chile)',
            onTap: () {},
          ),

          SettingItem(
            icon: Icons.dark_mode,
            title: 'Tema',
            subtitle: 'Claro',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF7f8c8d).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF7f8c8d), size: 20),
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
        style: const TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF7f8c8d)),
      onTap: onTap,
    );
  }
}

class ActionsSection extends StatelessWidget {
  final VoidCallback onChangePassword;

  const ActionsSection({super.key, required this.onChangePassword});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ModernButton(
            text: 'Cambiar Contraseña',
            style: ModernButtonStyle.secondary,
            icon: Icons.lock,
            onPressed: onChangePassword,
          ),
        ),
      ],
    );
  }
}
