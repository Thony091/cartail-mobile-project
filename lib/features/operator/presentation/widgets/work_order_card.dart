import 'package:flutter/material.dart';
import '../../domain/entities/work_order.dart';
import 'work_phase_widgets.dart';

/// Tarjeta de orden de trabajo para la lista del operario
class WorkOrderCard extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback? onTap;
  final VoidCallback? onQuickAction;

  const WorkOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: order.priority == WorkPriority.urgent
                ? const Color(0xFFe74c3c).withValues(alpha: 0.3)
                : const Color(0xFFe2e8f0),
            width: order.priority == WorkPriority.urgent ? 2 : 1,
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
          children: [
            // Header con prioridad y numero de orden
            _CardHeader(order: order),

            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de trabajo y fase
                  Row(
                    children: [
                      WorkTypeBadge(workType: order.workType),
                      const SizedBox(width: 8),
                      WorkPhaseBadge(phase: order.currentPhase),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Titulo
                  Text(
                    order.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Vehiculo
                  _VehicleRow(vehicle: order.vehicle),

                  const SizedBox(height: 12),

                  // Cliente
                  _ClientRow(
                    clientName: order.clientName,
                    clientPhone: order.clientPhone,
                  ),

                  const SizedBox(height: 16),

                  // Barra de progreso
                  WorkProgressBar(
                    progress: order.progressPercentage,
                    currentPhase: order.currentPhase,
                  ),

                  // Tiempo y acciones
                  const SizedBox(height: 16),
                  _FooterRow(
                    order: order,
                    onQuickAction: onQuickAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final WorkOrder order;

  const _CardHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _getHeaderColor().withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        children: [
          // Numero de orden
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFe2e8f0)),
            ),
            child: Text(
              '#${order.orderNumber}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
                fontFamily: 'monospace',
              ),
            ),
          ),

          const Spacer(),

          // Prioridad
          WorkPriorityBadge(priority: order.priority),

          if (order.priority != WorkPriority.normal &&
              order.priority != WorkPriority.low)
            const SizedBox(width: 8),

          // Tiempo estimado
          if (order.estimatedMinutes != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule,
                  size: 14,
                  color: Color(0xFF95a5a6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(order.estimatedMinutes!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF95a5a6),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getHeaderColor() {
    if (order.priority == WorkPriority.urgent) {
      return const Color(0xFFe74c3c);
    }
    if (order.priority == WorkPriority.high) {
      return const Color(0xFFe67e22);
    }
    return const Color(0xFF3498db);
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}m';
  }
}

class _VehicleRow extends StatelessWidget {
  final VehicleInfo vehicle;

  const _VehicleRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.directions_car,
          size: 18,
          color: const Color(0xFF3498db).withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${vehicle.fullName} - ${vehicle.licensePlate}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF34495e),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF7f8c8d).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            vehicle.color,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClientRow extends StatelessWidget {
  final String clientName;
  final String clientPhone;

  const _ClientRow({
    required this.clientName,
    required this.clientPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.person_outline,
          size: 18,
          color: Color(0xFF95a5a6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            clientName,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Llamar al cliente
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: Color(0xFF27ae60),
              ),
              const SizedBox(width: 4),
              Text(
                clientPhone,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF27ae60),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterRow extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback? onQuickAction;

  const _FooterRow({
    required this.order,
    this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tiempo desde creacion o inicio
        Icon(
          Icons.access_time,
          size: 16,
          color: const Color(0xFF95a5a6).withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          _getTimeText(),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF95a5a6),
          ),
        ),

        const Spacer(),

        // Boton de accion rapida
        if (order.nextPhase != null && onQuickAction != null)
          TextButton.icon(
            onPressed: onQuickAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor:
                  const Color(0xFF3498db).withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(
              _getActionIcon(),
              size: 18,
              color: const Color(0xFF3498db),
            ),
            label: Text(
              _getActionText(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3498db),
              ),
            ),
          ),
      ],
    );
  }

  String _getTimeText() {
    if (order.startedAt != null) {
      final elapsed = order.elapsedTime!;
      if (elapsed.inHours > 0) {
        return 'En trabajo: ${elapsed.inHours}h ${elapsed.inMinutes % 60}m';
      }
      return 'En trabajo: ${elapsed.inMinutes}m';
    }
    return _formatTimeAgo(order.createdAt);
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      return 'Hace ${diff.inHours}h';
    }
    return 'Hace ${diff.inDays}d';
  }

  IconData _getActionIcon() {
    switch (order.currentPhase) {
      case WorkPhase.pendingReception:
        return Icons.inventory_2;
      case WorkPhase.received:
        return Icons.search;
      case WorkPhase.diagnosis:
        return Icons.play_arrow;
      case WorkPhase.inProgress:
        return Icons.verified;
      case WorkPhase.waitingParts:
        return Icons.refresh;
      case WorkPhase.qualityCheck:
        return Icons.check_circle;
      case WorkPhase.completed:
        return Icons.local_shipping;
      default:
        return Icons.arrow_forward;
    }
  }

  String _getActionText() {
    switch (order.currentPhase) {
      case WorkPhase.pendingReception:
        return 'Recibir';
      case WorkPhase.received:
        return 'Diagnosticar';
      case WorkPhase.diagnosis:
        return 'Iniciar';
      case WorkPhase.inProgress:
        return 'Completar';
      case WorkPhase.waitingParts:
        return 'Continuar';
      case WorkPhase.qualityCheck:
        return 'Aprobar';
      case WorkPhase.completed:
        return 'Entregar';
      default:
        return 'Avanzar';
    }
  }
}

/// Tarjeta compacta para vistas resumidas
class WorkOrderCompactCard extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback? onTap;

  const WorkOrderCompactCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFe2e8f0)),
        ),
        child: Row(
          children: [
            // Icono de tipo de trabajo
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getTypeIcon(),
                color: _getTypeColor(),
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF95a5a6),
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      WorkPhaseBadge(
                        phase: order.currentPhase,
                        showIcon: false,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2c3e50),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.vehicle.fullName} - ${order.vehicle.licensePlate}',
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

            // Flecha
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFbdc3c7),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (order.workType) {
      case WorkType.detailing:
        return const Color(0xFF3498db);
      case WorkType.mechanicalRepair:
        return const Color(0xFFe67e22);
      case WorkType.oilChange:
        return const Color(0xFF8e44ad);
      case WorkType.tireService:
        return const Color(0xFF34495e);
      case WorkType.paintJob:
        return const Color(0xFF9b59b6);
      case WorkType.electrical:
        return const Color(0xFFf39c12);
      case WorkType.cameraInstallation:
      case WorkType.sensorInstallation:
      case WorkType.audioInstallation:
      case WorkType.accessoryInstallation:
        return const Color(0xFF1abc9c);
      default:
        return const Color(0xFF27ae60);
    }
  }

  IconData _getTypeIcon() {
    switch (order.workType) {
      case WorkType.detailing:
        return Icons.cleaning_services;
      case WorkType.mechanicalRepair:
        return Icons.build;
      case WorkType.oilChange:
        return Icons.oil_barrel;
      case WorkType.tireService:
        return Icons.tire_repair;
      case WorkType.paintJob:
        return Icons.format_paint;
      case WorkType.electrical:
        return Icons.electrical_services;
      case WorkType.cameraInstallation:
        return Icons.videocam;
      case WorkType.sensorInstallation:
        return Icons.sensors;
      case WorkType.audioInstallation:
        return Icons.speaker;
      case WorkType.accessoryInstallation:
        return Icons.extension;
      case WorkType.generalMaintenance:
        return Icons.handyman;
      case WorkType.other:
        return Icons.miscellaneous_services;
    }
  }
}
