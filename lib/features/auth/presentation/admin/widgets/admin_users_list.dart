import 'package:flutter/material.dart';
import 'package:portafolio_project/features/auth/data/models/admin_response_models.dart';

class AdminUsersList extends StatelessWidget {
  final List<AdminUserModel> users;
  final void Function(AdminUserModel user) onOpenActions;

  const AdminUsersList({
    super.key,
    required this.users,
    required this.onOpenActions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        return AdminUserCard(
          user: user,
          onOpenActions: () => onOpenActions(user),
        );
      },
    );
  }
}

class AdminUserCard extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onOpenActions;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.onOpenActions,
  });

  static const Map<String, IconData> _roleIcons = {
    'admin': Icons.admin_panel_settings,
    'operator': Icons.engineering,
    'user': Icons.person,
    'guest': Icons.visibility,
  };

  static const Map<String, Color> _roleColors = {
    'admin': Color(0xFFe74c3c),
    'operator': Color(0xFF9b59b6),
    'user': Color(0xFF3498db),
    'guest': Color(0xFF95a5a6),
  };

  @override
  Widget build(BuildContext context) {
    final role = (user.role ?? 'user').toLowerCase();
    final roleColor = _roleColors[role] ?? const Color(0xFF3498db);
    final roleIcon = _roleIcons[role] ?? Icons.person;
    final statusColor = user.isCurrentlyBanned
        ? const Color(0xFFe74c3c)
        : const Color(0xFF27ae60);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenActions,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar con gradiente
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        roleColor.withValues(alpha: 0.2),
                        roleColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: roleColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    user.isCurrentlyBanned ? Icons.block : roleIcon,
                    color: roleColor,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Información del usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name?.isNotEmpty == true
                                  ? user.name!
                                  : 'Sin nombre',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2c3e50),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Badge de estado
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.isCurrentlyBanned
                                      ? Icons.block
                                      : Icons.check_circle,
                                  size: 12,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.isCurrentlyBanned ? 'Baneado' : 'Activo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Email
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Rol y más opciones
                      Row(
                        children: [
                          // Badge de rol
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  roleIcon,
                                  size: 14,
                                  color: roleColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: roleColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Botón de acciones
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.more_horiz,
                              size: 18,
                              color: Color(0xFF667eea),
                            ),
                          ),
                        ],
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
}
