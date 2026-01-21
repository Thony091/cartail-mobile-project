import 'package:flutter/material.dart';
import '../../domain/entities/service_status.dart';

/// Badge que muestra el estado actual del servicio
class ServiceStatusBadge extends StatelessWidget {
  final ServiceStatus status;
  final bool showIcon;

  const ServiceStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getColor().withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_getIcon(), size: 16, color: _getColor()),
            const SizedBox(width: 6),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _getColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case ServiceStatus.received:
        return const Color(0xFFe67e22);
      case ServiceStatus.inProgress:
        return const Color(0xFF3498db);
      case ServiceStatus.ready:
        return const Color(0xFF27ae60);
      case ServiceStatus.delivered:
        return const Color(0xFF95a5a6);
    }
  }

  IconData _getIcon() {
    switch (status) {
      case ServiceStatus.received:
        return Icons.inbox;
      case ServiceStatus.inProgress:
        return Icons.build;
      case ServiceStatus.ready:
        return Icons.check_circle;
      case ServiceStatus.delivered:
        return Icons.done_all;
    }
  }
}

/// Barra de progreso visual del servicio
class ServiceProgressBar extends StatelessWidget {
  final ServiceStatus status;

  const ServiceProgressBar({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _ProgressStep(
              label: 'Recibido',
              icon: Icons.inbox,
              isCompleted: status.order >= 1,
              isCurrent: status == ServiceStatus.received,
            ),
            _ProgressLine(isCompleted: status.order >= 2),
            _ProgressStep(
              label: 'En Proceso',
              icon: Icons.build,
              isCompleted: status.order >= 2,
              isCurrent: status == ServiceStatus.inProgress,
            ),
            _ProgressLine(isCompleted: status.order >= 3),
            _ProgressStep(
              label: 'Listo',
              icon: Icons.check_circle,
              isCompleted: status.order >= 3,
              isCurrent: status == ServiceStatus.ready,
            ),
            _ProgressLine(isCompleted: status.order >= 4),
            _ProgressStep(
              label: 'Entregado',
              icon: Icons.done_all,
              isCompleted: status.order >= 4,
              isCurrent: status == ServiceStatus.delivered,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;

  const _ProgressStep({
    required this.label,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? const Color(0xFF27ae60)
        : const Color(0xFFbdc3c7);

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? color.withValues(alpha: 0.1)
                : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: isCurrent ? 3 : 2,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCompleted
                ? const Color(0xFF2c3e50)
                : const Color(0xFF95a5a6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final bool isCompleted;

  const _ProgressLine({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 28),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF27ae60)
              : const Color(0xFFe2e8f0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Timeline de actualizaciones del servicio
class ServiceStatusTimeline extends StatelessWidget {
  final List<StatusUpdate> updates;

  const ServiceStatusTimeline({
    super.key,
    required this.updates,
  });

  @override
  Widget build(BuildContext context) {
    final sortedUpdates = List<StatusUpdate>.from(updates)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < sortedUpdates.length; i++)
          _TimelineItem(
            update: sortedUpdates[i],
            isFirst: i == 0,
            isLast: i == sortedUpdates.length - 1,
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final StatusUpdate update;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.update,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(update.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea y punto
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: const Color(0xFFe2e8f0),
                  ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isFirst ? color : color.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                  ),
                  child: isFirst
                      ? Icon(
                          _getIcon(update.status),
                          size: 10,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFe2e8f0),
                    ),
                  ),
              ],
            ),
          ),
          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    update.status.displayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
                      color: const Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(update.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF95a5a6),
                    ),
                  ),
                  if (update.message != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf8fafc),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFe2e8f0)),
                      ),
                      child: Text(
                        update.message!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.received:
        return const Color(0xFFe67e22);
      case ServiceStatus.inProgress:
        return const Color(0xFF3498db);
      case ServiceStatus.ready:
        return const Color(0xFF27ae60);
      case ServiceStatus.delivered:
        return const Color(0xFF95a5a6);
    }
  }

  IconData _getIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.received:
        return Icons.inbox;
      case ServiceStatus.inProgress:
        return Icons.build;
      case ServiceStatus.ready:
        return Icons.check_circle;
      case ServiceStatus.delivered:
        return Icons.done_all;
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} minutos';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} horas';
    } else if (diff.inDays == 1) {
      return 'Ayer a las ${_formatTime(dt)}';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} a las ${_formatTime(dt)}';
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Card de información del vehículo para el usuario
class UserVehicleCard extends StatelessWidget {
  final UserVehicleInfo vehicle;

  const UserVehicleCard({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Color(0xFF3498db),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2c3e50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        vehicle.licensePlate,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      vehicle.color,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7f8c8d),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de resumen de servicio para la lista
class ServiceRequestCard extends StatelessWidget {
  final UserServiceRequest request;
  final VoidCallback onTap;

  const ServiceRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: request.isReady
                  ? const Color(0xFF27ae60).withValues(alpha: 0.3)
                  : const Color(0xFFe2e8f0),
              width: request.isReady ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2c3e50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${request.orderNumber}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const Spacer(),
                  ServiceStatusBadge(status: request.currentStatus),
                ],
              ),

              const SizedBox(height: 12),

              // Nombre del servicio
              Text(
                request.serviceName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),

              const SizedBox(height: 8),

              // Vehículo
              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 16,
                    color: Color(0xFF95a5a6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${request.vehicle.fullName} • ${request.vehicle.licensePlate}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7f8c8d),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Barra de progreso simple
              _SimpleProgressBar(progress: request.progressPercentage),

              const SizedBox(height: 12),

              // Footer con tiempo estimado o mensaje
              _CardFooter(request: request),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleProgressBar extends StatelessWidget {
  final double progress;

  const _SimpleProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progreso',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF95a5a6),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3498db),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFe2e8f0),
            valueColor: AlwaysStoppedAnimation(
              progress == 1.0
                  ? const Color(0xFF27ae60)
                  : const Color(0xFF3498db),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardFooter extends StatelessWidget {
  final UserServiceRequest request;

  const _CardFooter({required this.request});

  @override
  Widget build(BuildContext context) {
    if (request.isReady) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF27ae60).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.celebration,
              color: Color(0xFF27ae60),
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '¡Tu vehículo está listo para recoger!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF27ae60),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (request.isCompleted) {
      return Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Color(0xFF95a5a6),
          ),
          const SizedBox(width: 6),
          Text(
            'Entregado el ${_formatDate(request.completedAt!)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF95a5a6),
            ),
          ),
        ],
      );
    }

    final remaining = request.estimatedTimeRemaining;
    if (remaining != null) {
      return Row(
        children: [
          const Icon(
            Icons.schedule,
            size: 16,
            color: Color(0xFF3498db),
          ),
          const SizedBox(width: 6),
          Text(
            'Estimado: ${_formatDuration(remaining)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 24) {
      final days = duration.inDays;
      return '$days día${days > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes} minutos';
    }
  }
}

/// Card de mensaje de estado destacado
class StatusMessageCard extends StatelessWidget {
  final ServiceStatus status;

  const StatusMessageCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getColor().withValues(alpha: 0.1),
            _getColor().withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getColor().withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getColor().withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(),
              color: _getColor(),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              status.userFriendlyMessage,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _getColor(),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case ServiceStatus.received:
        return const Color(0xFFe67e22);
      case ServiceStatus.inProgress:
        return const Color(0xFF3498db);
      case ServiceStatus.ready:
        return const Color(0xFF27ae60);
      case ServiceStatus.delivered:
        return const Color(0xFF95a5a6);
    }
  }

  IconData _getIcon() {
    switch (status) {
      case ServiceStatus.received:
        return Icons.schedule;
      case ServiceStatus.inProgress:
        return Icons.engineering;
      case ServiceStatus.ready:
        return Icons.celebration;
      case ServiceStatus.delivered:
        return Icons.thumb_up;
    }
  }
}
