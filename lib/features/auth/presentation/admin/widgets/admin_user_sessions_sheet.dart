import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/data/models/admin_response_models.dart';
import 'package:portafolio_project/features/auth/data/models/better_auth_response_models.dart';

import '../../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../providers/admin_auth_provider.dart';

class AdminUserSessionsSheet extends ConsumerStatefulWidget {
  final AdminUserModel user;

  const AdminUserSessionsSheet({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<AdminUserSessionsSheet> createState() =>
      _AdminUserSessionsSheetState();
}

class _AdminUserSessionsSheetState
    extends ConsumerState<AdminUserSessionsSheet> {
  bool _actionLoading = false;

  void _showTopSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final topPadding = MediaQuery.of(context).padding.top;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFe74c3c) : const Color(0xFF27ae60),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 0),
        dismissDirection: DismissDirection.up,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(adminUserSessionsProvider.notifier)
          .listSessions(widget.user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionsState = ref.watch(adminUserSessionsProvider);
    final sessionsNotifier = ref.read(adminUserSessionsProvider.notifier);

    return AbsorbPointer(
      absorbing: _actionLoading,
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header con gradiente
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9b59b6), Color(0xFF8e44ad)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9b59b6).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.devices_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sesiones Activas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: sessionsState.isLoading
                          ? null
                          : () => sessionsNotifier.listSessions(widget.user.id),
                      icon: const Icon(
                        Icons.refresh_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Actualizar',
                    ),
                  ],
                ),
              ),

              // Lista de sesiones
              if (sessionsState.isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Cargando sesiones...',
                          style: TextStyle(color: Color(0xFF7f8c8d)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (sessionsState.sessions.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9b59b6).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.phonelink_off_outlined,
                            size: 64,
                            color: const Color(0xFF9b59b6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No hay sesiones activas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Este usuario no tiene dispositivos conectados',
                          style: TextStyle(color: Color(0xFF7f8c8d)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: sessionsState.sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final session = sessionsState.sessions[index];
                      return _SessionCard(
                        session: session,
                        onRevoke: () async {
                          if (_actionLoading) return;
                          setState(() => _actionLoading = true);
                          final ok = await sessionsNotifier
                              .revokeSession(session.token);
                          if (!context.mounted) return;
                          _showTopSnackBar(
                            ok
                                ? 'Sesión revocada'
                                : 'No se pudo revocar la sesión',
                            isError: !ok,
                          );
                          if (ok) {
                            Navigator.of(context).pop();
                          } else {
                            setState(() => _actionLoading = false);
                          }
                        },
                      );
                    },
                  ),
                ),

              // Botón de revocar todas
              if (sessionsState.sessions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Revocar todas las sesiones',
                      icon: Icons.logout_outlined,
                      style: ModernButtonStyle.danger,
                      onPressed: sessionsState.isLoading || _actionLoading
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('Confirmar'),
                                  content: const Text(
                                    '¿Estás seguro de que deseas revocar todas las sesiones? El usuario deberá iniciar sesión nuevamente en todos sus dispositivos.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ModernButton(
                                      text: 'Revocar todas',
                                      style: ModernButtonStyle.danger,
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed != true || !mounted) return;

                              setState(() => _actionLoading = true);
                              final ok = await sessionsNotifier
                                  .revokeAllSessions(widget.user.id);
                              if (!context.mounted) return;
                              _showTopSnackBar(
                                ok
                                    ? 'Todas las sesiones fueron revocadas'
                                    : 'No se pudieron revocar las sesiones',
                                isError: !ok,
                              );
                              if (ok) {
                                Navigator.of(context).pop();
                              } else {
                                setState(() => _actionLoading = false);
                              }
                            },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onRevoke;

  const _SessionCard({
    required this.session,
    required this.onRevoke,
  });

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    if (difference.inMinutes < 1) return 'Hace un momento';
    if (difference.inHours < 1) return 'Hace ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Hace ${difference.inHours} horas';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';

    return '${local.day}/${local.month}/${local.year}';
  }

  IconData _getDeviceIcon(String? userAgent) {
    if (userAgent == null) return Icons.devices_outlined;
    final ua = userAgent.toLowerCase();
    if (ua.contains('mobile') || ua.contains('android') || ua.contains('iphone')) {
      return Icons.phone_android_outlined;
    }
    if (ua.contains('tablet') || ua.contains('ipad')) {
      return Icons.tablet_outlined;
    }
    return Icons.computer_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = session.isExpired;
    final statusColor = isExpired ? const Color(0xFFe74c3c) : const Color(0xFF27ae60);
    final deviceIcon = _getDeviceIcon(session.userAgent);

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    deviceIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.ipAddress ?? 'IP desconocida',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2c3e50),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isExpired ? Icons.timer_off : Icons.check_circle,
                                  size: 14,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isExpired ? 'Expirada' : 'Activa',
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
                      if (session.userAgent != null)
                        Text(
                          session.userAgent!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7f8c8d),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  'Expira: ${_formatDateTime(session.expiresAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                ModernButton(
                  text: 'Revocar',
                  icon: Icons.logout_outlined,
                  style: ModernButtonStyle.danger,
                  onPressed: onRevoke,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
